"""Resolve Google all-day dates at midnight in the calendar's IANA timezone.

The short-lived helper uses the system timezone database, including DST rules.
Only date strings and a timezone name are passed; no credentials or event text.
"""
import base64
from datetime import date, datetime, time
import json
import sys
from zoneinfo import ZoneInfo


def resolve(payload):
    zone = ZoneInfo(payload["zone"])
    return {
        value: int(datetime.combine(date.fromisoformat(value), time(), zone).timestamp() * 1000)
        for value in payload["dates"]
    }


if __name__ == "__main__":
    print(json.dumps(resolve(json.loads(base64.b64decode(sys.argv[1])))))
