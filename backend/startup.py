#!/usr/bin/env python3
"""Startup script for Railway deployment - reads PORT from environment."""
import os
import sys
import traceback

def main():
    try:
        # Read PORT from environment, default to 8000
        port = int(os.environ.get("PORT", "8000"))
        host = os.environ.get("HOST", "0.0.0.0")
        
        print(f"Starting server on {host}:{port}")
        print(f"DATABASE_URL is {'set' if os.environ.get('DATABASE_URL') else 'not set'}")
        
        # Import app first to check for errors
        print("Importing app...")
        from app import app
        print("App imported successfully")
        
        # Import uvicorn and run the app
        import uvicorn
        print(f"Starting uvicorn on {host}:{port}")
        uvicorn.run(
            "app:app",
            host=host,
            port=port,
            log_level="info",
            access_log=True
        )
    except Exception as e:
        print(f"FATAL ERROR during startup: {type(e).__name__}: {e}")
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()

