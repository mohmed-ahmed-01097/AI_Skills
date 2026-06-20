#!/usr/bin/env python3
"""Evaluate MATLAB code in an already-running shared MATLAB session.

Description:
    Connects to a MATLAB session that was shared with matlab.engine.shareEngine
    and evaluates either inline MATLAB code or a MATLAB file in that existing
    session. This is intended for local agent/CMD workflows where MATLAB Desktop
    must remain open and reused, rather than starting a brand-new MATLAB process.

Requirements:
    - MATLAB Engine API for Python installed for the active Python environment.
    - An open MATLAB session that has executed matlab.engine.shareEngine.

Examples:
    python matlab_shared_engine_eval.py --list
    python matlab_shared_engine_eval.py --code "assert(1+1==2); disp('ASSERT_TEST_PASS')"
    python matlab_shared_engine_eval.py --file C:\\path\\to\\script.m
    python matlab_shared_engine_eval.py --engine-name MATLAB_12345 --code "disp(pwd)"
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


def _matlab_path_literal(path: pathlib.Path) -> str:
    """Build a single-quoted MATLAB char-array literal for an absolute path.

    Uses forward slashes (MATLAB accepts these on every platform, including
    Windows) and doubles any single quotes per MATLAB char-array escaping
    rules, so the result is always a safe, explicit literal rather than
    relying on Python repr() formatting tricks.
    """
    posix_like = path.as_posix()
    escaped = posix_like.replace("'", "''")
    return f"'{escaped}'"


def main() -> int:
    parser = argparse.ArgumentParser(description="Evaluate code in a shared MATLAB session.")
    parser.add_argument("--code", help="MATLAB code to evaluate in the shared session.")
    parser.add_argument("--file", help="MATLAB .m file to run in the shared session.")
    parser.add_argument(
        "--engine-name",
        help="Specific shared MATLAB engine name from --list. Required when more than "
             "one shared session exists, since guessing could run code against the wrong project.",
    )
    parser.add_argument("--list", action="store_true", help="List shared MATLAB sessions and exit.")
    args = parser.parse_args()

    if args.code and args.file:
        print("ERROR: Provide only one of --code or --file, not both.", file=sys.stderr)
        return 2

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
            print("In MATLAB Desktop, run: matlab.engine.shareEngine", file=sys.stderr)
        return 0

    if not args.code and not args.file:
        print("ERROR: Provide --code, --file, or --list.", file=sys.stderr)
        return 2

    if not engines:
        print("ERROR: No shared MATLAB sessions found.", file=sys.stderr)
        print("In MATLAB Desktop, run: matlab.engine.shareEngine", file=sys.stderr)
        return 4

    if args.engine_name:
        engine_name = args.engine_name
    elif len(engines) == 1:
        engine_name = engines[0]
    else:
        # More than one shared session exists. Do not silently guess which one
        # the user means -- connecting to the wrong session can edit the wrong
        # project's models, workspace, or files.
        print("ERROR: Multiple shared MATLAB sessions found. Pass --engine-name to pick one:", file=sys.stderr)
        for name in engines:
            print(f"  {name}", file=sys.stderr)
        return 4

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
            matlab_code = f"run({_matlab_path_literal(script_path)})"
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
