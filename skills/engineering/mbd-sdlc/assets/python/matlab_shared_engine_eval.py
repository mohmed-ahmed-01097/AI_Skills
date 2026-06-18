#!/usr/bin/env python3
"""Evaluate MATLAB code in an already-running shared MATLAB session.

Description:
    Connects to a MATLAB session that was shared with matlab.engine.shareEngine
    and evaluates either inline MATLAB code or a MATLAB file in that existing
    session. This is intended for local agent/CMD workflows where MATLAB Desktop
    must remain open and reused.

Requirements:
    - MATLAB Engine API for Python installed for the active Python environment.
    - An open MATLAB session that has executed matlab.engine.shareEngine.

Examples:
    python matlab_shared_engine_eval.py --list
    python matlab_shared_engine_eval.py --code "assert(1+1==2); disp('ASSERT_TEST_PASS')"
    python matlab_shared_engine_eval.py --file C:\\path\\to\\script.m
"""

from __future__ import annotations

import argparse
import pathlib
import sys


def _import_engine():
    try:
        import matlab.engine  # type: ignore
    except Exception as exc:  # pragma: no cover - depends on local MATLAB setup
        print("ERROR: Could not import matlab.engine.", file=sys.stderr)
        print("Install/configure the MATLAB Engine API for Python for this Python environment.", file=sys.stderr)
        print(f"Import error: {exc}", file=sys.stderr)
        return None
    return matlab.engine


def main() -> int:
    parser = argparse.ArgumentParser(description="Evaluate code in a shared MATLAB session.")
    parser.add_argument("--code", help="MATLAB code to evaluate in the shared session.")
    parser.add_argument("--file", help="MATLAB .m file to run in the shared session.")
    parser.add_argument("--engine-name", help="Specific shared MATLAB engine name. If omitted, use the first available shared session.")
    parser.add_argument("--list", action="store_true", help="List shared MATLAB sessions and exit.")
    args = parser.parse_args()

    matlab_engine = _import_engine()
    if matlab_engine is None:
        return 2

    try:
        engines = matlab_engine.find_matlab()
    except Exception as exc:
        print(f"ERROR: Could not query shared MATLAB sessions: {exc}", file=sys.stderr)
        return 3

    if args.list:
        if engines:
            for name in engines:
                print(name)
        else:
            print("No shared MATLAB sessions found.")
        return 0

    if not args.code and not args.file:
        print("ERROR: Provide --code, --file, or --list.", file=sys.stderr)
        return 2

    if not engines and not args.engine_name:
        print("ERROR: No shared MATLAB sessions found.", file=sys.stderr)
        print("In MATLAB Desktop, run: matlab.engine.shareEngine", file=sys.stderr)
        return 4

    engine_name = args.engine_name or engines[0]
    try:
        eng = matlab_engine.connect_matlab(engine_name)
    except Exception as exc:
        print(f"ERROR: Could not connect to shared MATLAB session '{engine_name}': {exc}", file=sys.stderr)
        return 5

    try:
        if args.file:
            script_path = pathlib.Path(args.file).expanduser().resolve()
            if not script_path.is_file():
                print(f"ERROR: MATLAB file not found: {script_path}", file=sys.stderr)
                return 6
            # Use run with a normalized path to preserve the user's current MATLAB session.
            matlab_code = "run(" + repr(str(script_path)).replace("\\\\", "/") + ")"
            eng.eval(matlab_code, nargout=0)
        else:
            eng.eval(args.code, nargout=0)
    except Exception as exc:
        print("MATLAB_SHARED_ENGINE_EVAL_FAIL", file=sys.stderr)
        print(str(exc), file=sys.stderr)
        return 1

    print("MATLAB_SHARED_ENGINE_EVAL_PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
