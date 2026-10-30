# Local verifier check: python3 tools/run_verifier.py <task>/tests <output file>
"""Run <tests_dir>/test_outputs.py against a given output file (local check).
Points whichever of PLAN, SCHEDULE or PRICES the verifier module defines at the file."""
import sys
from pathlib import Path
import pytest
tests_dir, out = Path(sys.argv[1]), Path(sys.argv[2])
sys.path.insert(0, str(tests_dir))
class Patch:
    def pytest_collection_modifyitems(self, session, config, items):
        mod = sys.modules["test_outputs"]
        for name in ("PLAN", "SCHEDULE", "PRICES"):
            if hasattr(mod, name):
                setattr(mod, name, out)
rc = pytest.main(["-q", "-p", "no:cacheprovider", str(tests_dir / "test_outputs.py")], plugins=[Patch()])
print("REWARD", 1 if rc == 0 else 0)
