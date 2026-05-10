"""
Tiny scoreboard simulator, modeling a CDC-6600-flavored CPU with
3 functional units, register file, and dynamic in-order issue with
out-of-order completion.

Instruction format (one per line):
    OP DEST SRC1 SRC2     for arithmetic ops (ADD, MUL)
    OP DEST ADDR          for LOAD
    OP                    for HALT

Registers are R0..R7. Latencies are configurable below.
"""
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Optional

# Latencies (cycles) — tweak to see the effect.
LATENCIES = {"ADD": 2, "MUL": 4, "LOAD": 3}

@dataclass
class Instr:
    op: str
    dest: str
    src1: Optional[str] = None
    src2: Optional[str] = None
    issue_cycle: int = -1
    complete_cycle: int = -1

class Scoreboard:
    def __init__(self):
        # Which register is currently being written by an in-flight instr?
        self.regs_busy_writing: dict[str, Instr] = {}
        # Currently executing units {unit_name: (instr, complete_cycle)}
        self.busy_unit: dict[str, tuple[Instr, int]] = {}
        self.cycle = 0
        self.completed: list[Instr] = []

    def can_issue(self, instr: Instr) -> bool:
        """Return True if instr has no hazards and a free unit."""
        unit = instr.op
        # Structural hazard: is the unit free?
        if unit in self.busy_unit:
            return False
        # WAW: dest cannot be a register currently being written
        if instr.dest in self.regs_busy_writing:
            return False
        # RAW: sources cannot be registers currently being written
        # TODO (student): implement RAW check below.
        for src in (instr.src1, instr.src2):
            if src is None:
                continue
            if src in self.regs_busy_writing:
                return False
        # (WAR is not an issue here because we have no register renaming
        # AND we only block on WAW + RAW. In a more aggressive scoreboard
        # WAR would also need handling.)
        return True

    def issue(self, instr: Instr):
        instr.issue_cycle = self.cycle
        instr.complete_cycle = self.cycle + LATENCIES[instr.op]
        self.busy_unit[instr.op] = (instr, instr.complete_cycle)
        self.regs_busy_writing[instr.dest] = instr

    def step_complete(self):
        """Drain any units that finish this cycle."""
        finished = []
        for unit, (instr, ccycle) in list(self.busy_unit.items()):
            if ccycle == self.cycle:
                finished.append((unit, instr))
        for unit, instr in finished:
            del self.busy_unit[unit]
            # Free the destination register only if no later instr also targets it
            if self.regs_busy_writing.get(instr.dest) is instr:
                del self.regs_busy_writing[instr.dest]
            self.completed.append(instr)

    def all_done(self, n: int) -> bool:
        return len(self.completed) == n


def parse(line: str) -> Optional[Instr]:
    line = line.strip()
    if not line or line.startswith("#"):
        return None
    parts = line.split()
    op = parts[0].upper()
    if op == "HALT":
        return None
    if op == "LOAD":
        return Instr(op, parts[1], parts[2], None)
    return Instr(op, parts[1], parts[2], parts[3])


def run(program_path: str):
    with open(program_path) as f:
        program = [p for p in (parse(ln) for ln in f) if p is not None]

    sb = Scoreboard()
    pc = 0
    while not sb.all_done(len(program)):
        # Drain completions first
        sb.step_complete()
        # Try to issue next instruction
        if pc < len(program):
            instr = program[pc]
            if sb.can_issue(instr):
                sb.issue(instr)
                pc += 1
        sb.cycle += 1
        if sb.cycle > 1000:
            raise RuntimeError("Stuck — a bug in your hazard logic?")

    print(f"\nProgram '{program_path}' completed in {sb.cycle} cycles.")
    print(f"{'op':6s} {'dest':6s} {'issued':>8s} {'finished':>10s}")
    for i in sb.completed:
        print(f"{i.op:6s} {i.dest:6s} {i.issue_cycle:8d} {i.complete_cycle:10d}")


if __name__ == "__main__":
    import sys
    path = sys.argv[1] if len(sys.argv) > 1 else "programs/dot.txt"
    run(path)
