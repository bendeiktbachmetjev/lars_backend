import os
import asyncio
import asyncpg


async def main():
    url = os.getenv("DATABASE_URL")
    if not url:
        print("DATABASE_URL is not set")
        return
    # asyncpg does not understand postgresql+asyncpg, ensure plain scheme
    if url.startswith("postgresql+asyncpg://"):
        url = "postgresql://" + url[len("postgresql+asyncpg://") :]
    if url.startswith("postgres+asyncpg://"):
        url = "postgresql://" + url[len("postgres+asyncpg://") :]
    conn = await asyncpg.connect(dsn=url)
    try:
        val = await conn.fetchval("SELECT 1")
        print({"db_select_1": val})
        ext = await conn.fetch("SELECT extname FROM pg_extension ORDER BY 1")
        print({"extensions": [r[0] for r in ext]})
    finally:
        await conn.close()


if __name__ == "__main__":
    asyncio.run(main())



