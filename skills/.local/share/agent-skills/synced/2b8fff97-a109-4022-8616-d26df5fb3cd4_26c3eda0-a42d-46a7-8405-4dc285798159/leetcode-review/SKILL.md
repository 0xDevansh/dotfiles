---
name: leetcode-review
description: >
  Reviews a user's LeetCode solution and identifies concrete improvements across
  correctness, performance, and code quality. Trigger this skill whenever the user
  shares a LeetCode solution and asks how to improve it, what's wrong with it, or
  how it could be better — including via the /leetcode slash command. Also trigger
  when the user pastes competitive programming code with a problem title or number
  and asks for feedback, critique, or optimization advice.
---

# LeetCode Solution Review

## Input

The user provides:
- **Problem**: title, number, or description. If missing and the problem is not
  well-known, ask for it before proceeding.
- **Solution**: code in any language (C++ most common).

If the problem statement is ambiguous or unknown, ask once. Otherwise proceed
directly — don't ask for clarification you can infer.

---

## Review Structure

Produce a focused, high-signal review. No filler. Each point must be actionable.

### 1. Bugs / Correctness
- Logic errors, off-by-one, wrong base cases, incorrect termination conditions.
- Wrong placement of checks (e.g. early return inside a loop when it should be before it).
- Anything that causes WA or produces wrong output on edge cases.

### 2. Complexity
- State actual time and space complexity of their solution.
- If a better complexity is achievable, state it and briefly how.
- Only flag this if there's a meaningful improvement (e.g. O(n²) → O(n log n), not O(n) → O(n) with smaller constant).

### 3. Hot Path Optimizations
- Unnecessary heap allocations inside recursive calls or tight loops (e.g. constructing `vector` inside a function called 10⁵ times).
- Redundant work inside the loop that can be hoisted out.
- Use of slow data structures where faster alternatives exist (e.g. `unordered_map<char,int>` → `int[128]`).

### 4. Code Quality / Idioms
- Use of language features that are cleaner or more correct (e.g. `word.back()` vs `word[word.size()-1]`).
- Debug artifacts left in (e.g. `cout`, `printf`).
- Member variables that should be local, or vice versa.
- Naming, unnecessary state.

### 5. Pruning / Heuristics (if applicable)
- Frequency checks, early exit conditions, search-order heuristics.
- Evaluate correctness of any existing pruning the user implemented — flag subtle mistakes.

---

## Format Rules

- Lead with the most impactful issue.
- Use a bold header per category, skip categories with nothing meaningful to say.
- Show before/after code snippets for non-obvious fixes. Keep them minimal.
- Do not pad with praise or restate what the code does correctly unless it's
  a common misconception worth noting.
- If the solution is already optimal and clean, say so directly with a brief
  complexity confirmation.

---

## Slash Command: /leetcode

When invoked as `/leetcode`, expect:
```
/leetcode
<problem title or number>
<solution code>
```

If either is missing, ask for it. Then apply the full review above.
