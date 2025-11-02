#!/usr/bin/env python3
"""Startup script for Railway deployment - reads PORT from environment."""
import os
import sys
import traceback
import logging

# Configure logging to stdout (Railway captures stdout)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)

logger = logging.getLogger(__name__)

def main():
    try:
        # Read PORT from environment, default to 8000
        port = int(os.environ.get("PORT", "8000"))
        host = os.environ.get("HOST", "0.0.0.0")
        
        logger.info(f"Starting server on {host}:{port}")
        logger.info(f"DATABASE_URL is {'set' if os.environ.get('DATABASE_URL') else 'not set'}")
        
        # Import app first to check for errors
        logger.info("Importing app module...")
        from app import app
        logger.info("App module imported successfully")
        
        # Import uvicorn and run the app
        import uvicorn
        logger.info(f"Starting uvicorn server on {host}:{port}")
        logger.info("Server should be ready to accept connections")
        
        uvicorn.run(
            "app:app",
            host=host,
            port=port,
            log_level="info",
            access_log=True,
            log_config=None  # Use uvicorn's default logging
        )
    except KeyboardInterrupt:
        logger.info("Server interrupted by user")
        sys.exit(0)
    except Exception as e:
        logger.error(f"FATAL ERROR during startup: {type(e).__name__}: {e}")
        logger.error(traceback.format_exc())
        sys.exit(1)

if __name__ == "__main__":
    main()

