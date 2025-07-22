#!/usr/bin/env python3
"""
AI-Powered Log Analyzer for Loki

This script provides AI-powered log analysis capabilities by:
1. Fetching logs from Loki
2. Generating embeddings using sentence transformers
3. Storing in a vector database for semantic search
4. Providing intelligent log analysis and alerting

Requirements:
pip install requests chromadb sentence-transformers python-telegram-bot
"""

import requests
import json
import time
import logging
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional
import argparse
import os

try:
    import chromadb
    from sentence_transformers import SentenceTransformer
    import telegram
    import asyncio
except ImportError as e:
    print(f"Missing required package: {e}")
    print("Install with: pip install requests chromadb sentence-transformers python-telegram-bot")
    exit(1)

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class AILogAnalyzer:
    def __init__(self, loki_url: str, model_name: str = 'all-MiniLM-L6-v2'):
        """
        Initialize the AI Log Analyzer
        
        Args:
            loki_url: Loki service URL
            model_name: Sentence transformer model to use
        """
        self.loki_url = loki_url.rstrip('/')
        self.model = SentenceTransformer(model_name)
        self.chroma_client = chromadb.Client()
        
        # Create or get collection
        try:
            self.collection = self.chroma_client.get_collection("logs")
        except:
            self.collection = self.chroma_client.create_collection("logs")
        
        logger.info(f"Initialized AI Log Analyzer with model: {model_name}")
    
    def fetch_logs_from_loki(self, query: str, start_time: str, end_time: str, limit: int = 1000) -> Dict[str, Any]:
        """
        Fetch logs from Loki using LogQL query
        
        Args:
            query: LogQL query string
            start_time: Start time in ISO format
            end_time: End time in ISO format
            limit: Maximum number of logs to fetch
            
        Returns:
            Dictionary containing log data
        """
        try:
            params = {
                'query': query,
                'start': start_time,
                'end': end_time,
                'limit': limit
            }
            
            response = requests.get(f"{self.loki_url}/loki/api/v1/query_range", params=params, timeout=30)
            response.raise_for_status()
            
            return response.json()
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to fetch logs from Loki: {e}")
            return {"data": {"result": []}}
    
    def process_logs(self, logs_data: Dict[str, Any], batch_size: int = 100) -> int:
        """
        Process logs and store embeddings in vector database
        
        Args:
            logs_data: Log data from Loki
            batch_size: Number of logs to process in each batch
            
        Returns:
            Number of logs processed
        """
        if not logs_data.get('data', {}).get('result'):
            logger.info("No logs to process")
            return 0
        
        processed_count = 0
        all_logs = logs_data['data']['result']
        
        for i in range(0, len(all_logs), batch_size):
            batch = all_logs[i:i + batch_size]
            
            # Extract log contents and metadata
            documents = []
            metadatas = []
            ids = []
            
            for log in batch:
                try:
                    # Extract log content (timestamp and message)
                    timestamp_ns = int(log['values'][0][0])
                    log_content = log['values'][0][1]
                    
                    # Convert nanoseconds to readable timestamp
                    timestamp = datetime.fromtimestamp(timestamp_ns / 1e9).isoformat()
                    
                    # Create document ID
                    doc_id = f"{timestamp_ns}_{hash(log_content) % 1000000}"
                    
                    documents.append(log_content)
                    metadatas.append({
                        "timestamp": timestamp,
                        "timestamp_ns": timestamp_ns,
                        "stream": json.dumps(log['stream']),
                        "namespace": log['stream'].get('namespace', 'unknown'),
                        "pod": log['stream'].get('pod', 'unknown'),
                        "container": log['stream'].get('container', 'unknown'),
                        "job": log['stream'].get('job', 'unknown')
                    })
                    ids.append(doc_id)
                    
                except Exception as e:
                    logger.warning(f"Failed to process log entry: {e}")
                    continue
            
            if documents:
                try:
                    # Generate embeddings
                    embeddings = self.model.encode(documents).tolist()
                    
                    # Store in vector database
                    self.collection.add(
                        embeddings=embeddings,
                        documents=documents,
                        metadatas=metadatas,
                        ids=ids
                    )
                    
                    processed_count += len(documents)
                    logger.info(f"Processed batch of {len(documents)} logs")
                    
                except Exception as e:
                    logger.error(f"Failed to store batch in vector database: {e}")
        
        logger.info(f"Total logs processed: {processed_count}")
        return processed_count
    
    def search_logs_semantic(self, query: str, n_results: int = 10, 
                           filters: Optional[Dict[str, str]] = None) -> List[Dict[str, Any]]:
        """
        Perform semantic search on logs
        
        Args:
            query: Search query
            n_results: Number of results to return
            filters: Optional filters for metadata
            
        Returns:
            List of search results
        """
        try:
            # Generate query embedding
            query_embedding = self.model.encode(query).tolist()
            
            # Perform search
            results = self.collection.query(
                query_embeddings=[query_embedding],
                n_results=n_results,
                where=filters
            )
            
            # Format results
            formatted_results = []
            for i in range(len(results['documents'][0])):
                formatted_results.append({
                    'content': results['documents'][0][i],
                    'metadata': results['metadatas'][0][i],
                    'distance': results['distances'][0][i] if 'distances' in results else None
                })
            
            return formatted_results
            
        except Exception as e:
            logger.error(f"Failed to perform semantic search: {e}")
            return []
    
    def analyze_log_patterns(self, time_range: str = "1h") -> Dict[str, Any]:
        """
        Analyze log patterns for anomalies and insights
        
        Args:
            time_range: Time range to analyze (e.g., "1h", "24h")
            
        Returns:
            Analysis results
        """
        end_time = datetime.now()
        
        if time_range.endswith('h'):
            hours = int(time_range[:-1])
            start_time = end_time - timedelta(hours=hours)
        elif time_range.endswith('d'):
            days = int(time_range[:-1])
            start_time = end_time - timedelta(days=days)
        else:
            start_time = end_time - timedelta(hours=1)
        
        # Fetch recent logs
        logs_data = self.fetch_logs_from_loki(
            query='{job="kubernetes-pods"}',
            start_time=start_time.isoformat(),
            end_time=end_time.isoformat(),
            limit=1000
        )
        
        if not logs_data.get('data', {}).get('result'):
            return {"error": "No logs found for analysis"}
        
        # Analyze patterns
        analysis = {
            "time_range": time_range,
            "total_logs": len(logs_data['data']['result']),
            "namespaces": {},
            "error_patterns": [],
            "top_pods": {}
        }
        
        # Count by namespace
        for log in logs_data['data']['result']:
            namespace = log['stream'].get('namespace', 'unknown')
            pod = log['stream'].get('pod', 'unknown')
            content = log['values'][0][1].lower()
            
            # Count namespace logs
            if namespace not in analysis["namespaces"]:
                analysis["namespaces"][namespace] = 0
            analysis["namespaces"][namespace] += 1
            
            # Count pod logs
            if pod not in analysis["top_pods"]:
                analysis["top_pods"][pod] = 0
            analysis["top_pods"][pod] += 1
            
            # Check for error patterns
            if any(error_word in content for error_word in ['error', 'exception', 'fail', 'panic', 'crash']):
                analysis["error_patterns"].append({
                    "content": log['values'][0][1],
                    "namespace": namespace,
                    "pod": pod,
                    "timestamp": datetime.fromtimestamp(int(log['values'][0][0]) / 1e9).isoformat()
                })
        
        # Sort top pods
        analysis["top_pods"] = dict(sorted(analysis["top_pods"].items(), 
                                         key=lambda x: x[1], reverse=True)[:10])
        
        return analysis

class TelegramLogBot:
    def __init__(self, token: str, chat_id: str, loki_url: str):
        """
        Initialize Telegram bot for log alerts
        
        Args:
            token: Telegram bot token
            chat_id: Telegram chat ID
            loki_url: Loki service URL
        """
        self.bot = telegram.Bot(token=token)
        self.chat_id = chat_id
        self.loki_url = loki_url.rstrip('/')
    
    async def send_log_alert(self, query: str, time_range: str = "1h", max_logs: int = 5):
        """
        Send log alert to Telegram
        
        Args:
            query: LogQL query for alerts
            time_range: Time range to check
            max_logs: Maximum number of logs to include in alert
        """
        try:
            end_time = datetime.now()
            if time_range.endswith('h'):
                hours = int(time_range[:-1])
                start_time = end_time - timedelta(hours=hours)
            else:
                start_time = end_time - timedelta(hours=1)
            
            # Fetch logs
            params = {
                'query': query,
                'start': start_time.isoformat(),
                'end': end_time.isoformat(),
                'limit': max_logs
            }
            
            response = requests.get(f"{self.loki_url}/loki/api/v1/query_range", params=params, timeout=30)
            response.raise_for_status()
            
            logs_data = response.json()
            
            if logs_data.get('data', {}).get('result'):
                message = f"🚨 Log Alert ({time_range}):\n\n"
                
                for log in logs_data['data']['result'][:max_logs]:
                    timestamp = datetime.fromtimestamp(int(log['values'][0][0]) / 1e9).strftime('%H:%M:%S')
                    namespace = log['stream'].get('namespace', 'unknown')
                    pod = log['stream'].get('pod', 'unknown')
                    content = log['values'][0][1][:200] + "..." if len(log['values'][0][1]) > 200 else log['values'][0][1]
                    
                    message += f"⏰ {timestamp} | 📦 {namespace}/{pod}\n"
                    message += f"📝 {content}\n\n"
                
                await self.bot.send_message(chat_id=self.chat_id, text=message)
                logger.info(f"Sent log alert to Telegram")
            else:
                logger.info("No logs found for alert")
                
        except Exception as e:
            logger.error(f"Failed to send Telegram alert: {e}")

def main():
    parser = argparse.ArgumentParser(description='AI-Powered Log Analyzer for Loki')
    parser.add_argument('--loki-url', default='http://loki.logging.svc.cluster.local:3100',
                       help='Loki service URL')
    parser.add_argument('--action', choices=['fetch', 'search', 'analyze', 'alert'],
                       required=True, help='Action to perform')
    parser.add_argument('--query', default='{job="kubernetes-pods"}',
                       help='LogQL query')
    parser.add_argument('--time-range', default='1h',
                       help='Time range for analysis (e.g., 1h, 24h)')
    parser.add_argument('--search-query', help='Search query for semantic search')
    parser.add_argument('--telegram-token', help='Telegram bot token')
    parser.add_argument('--telegram-chat-id', help='Telegram chat ID')
    parser.add_argument('--max-results', type=int, default=10,
                       help='Maximum number of results')
    
    args = parser.parse_args()
    
    # Initialize analyzer
    analyzer = AILogAnalyzer(args.loki_url)
    
    if args.action == 'fetch':
        # Fetch and process logs
        end_time = datetime.now()
        start_time = end_time - timedelta(hours=1)
        
        logs_data = analyzer.fetch_logs_from_loki(
            query=args.query,
            start_time=start_time.isoformat(),
            end_time=end_time.isoformat()
        )
        
        processed = analyzer.process_logs(logs_data)
        print(f"Processed {processed} logs")
    
    elif args.action == 'search':
        # Perform semantic search
        if not args.search_query:
            print("Error: --search-query is required for search action")
            return
        
        results = analyzer.search_logs_semantic(args.search_query, args.max_results)
        
        print(f"Found {len(results)} results for query: '{args.search_query}'")
        for i, result in enumerate(results, 1):
            print(f"\n--- Result {i} ---")
            print(f"Content: {result['content']}")
            print(f"Namespace: {result['metadata']['namespace']}")
            print(f"Pod: {result['metadata']['pod']}")
            print(f"Timestamp: {result['metadata']['timestamp']}")
            if result['distance']:
                print(f"Similarity: {1 - result['distance']:.3f}")
    
    elif args.action == 'analyze':
        # Analyze log patterns
        analysis = analyzer.analyze_log_patterns(args.time_range)
        
        print(f"Log Analysis for {args.time_range}:")
        print(f"Total logs: {analysis['total_logs']}")
        print(f"\nNamespaces:")
        for ns, count in analysis['namespaces'].items():
            print(f"  {ns}: {count} logs")
        
        print(f"\nTop pods:")
        for pod, count in analysis['top_pods'].items():
            print(f"  {pod}: {count} logs")
        
        if analysis['error_patterns']:
            print(f"\nError patterns found: {len(analysis['error_patterns'])}")
            for error in analysis['error_patterns'][:5]:
                print(f"  {error['timestamp']} | {error['namespace']}/{error['pod']}")
                print(f"    {error['content'][:100]}...")
    
    elif args.action == 'alert':
        # Send Telegram alert
        if not args.telegram_token or not args.telegram_chat_id:
            print("Error: --telegram-token and --telegram-chat-id are required for alert action")
            return
        
        bot = TelegramLogBot(args.telegram_token, args.telegram_chat_id, args.loki_url)
        
        # Run async alert
        asyncio.run(bot.send_log_alert(args.query, args.time_range, args.max_results))

if __name__ == "__main__":
    main() 