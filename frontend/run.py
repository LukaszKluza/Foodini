import argparse
import os
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int, default=3000, help="Flutter port to run on")
    parser.add_argument(
        "--dart_define_from_file",
        type=str,
        default="config/dev-web.json",
        help="Flutter config",
    )

    args = parser.parse_args()

    if sys.platform.startswith("win"):
        flutter_cmd = "flutter.bat"
    else:
        flutter_cmd = "flutter"

    cmd = [
        flutter_cmd,
        "run",
        f"--web-port={args.port}",
        f"--dart-define-from-file={args.dart_define_from_file}",
    ]

    print("Running:", " ".join(cmd))
    env = os.environ.copy()
    subprocess.run(cmd, env=env)


if __name__ == "__main__":
    main()
