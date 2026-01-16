# Repository Guidelines

## Project Structure & Module Organization

- `modules/` holds Terraform modules for AWS infrastructure (e.g., `ecscluster`, `ecsservice`, `alb`, `kms`). Each module is self-contained with its own Terraform files.
- `envs/` contains Terragrunt configuration and environment wiring; `envs/root.hcl` defines shared inputs, and `envs/dev/` is the primary environment example.
- `src/` includes the Streamlit app (`app.py`) and its Docker build context (`Dockerfile`).
- `docker-bake.hcl` and `docker_buildx_bake.sh` define the Docker build workflow used before deploying.

## Build, Test, and Development Commands

- `./docker_buildx_bake.sh` builds the application image using Buildx and `docker-bake.hcl`.
- `terragrunt run-all init --working-dir='envs/dev/' -upgrade -reconfigure` initializes Terraform state for the dev environment.
- `terragrunt run-all plan --working-dir='envs/dev/'` produces a speculative plan.
- `terragrunt run-all apply --working-dir='envs/dev/' --non-interactive` applies infrastructure changes.
- `terragrunt run-all destroy --working-dir='envs/dev/' --non-interactive` tears down dev resources.
- `uv sync --extra dev` installs Python dependencies for local development.
- `uv run streamlit run src/app.py` runs the app locally.
- `uv run ruff check src/` and `uv run pyright src/` run linting and type checks.

## Coding Style & Naming Conventions

- Python: 4-space indentation, max line length 88, Google-style docstrings (`pydocstyle` via Ruff).
- Linting/formatting: Ruff is the primary style gate (`pyproject.toml`), with strict Pyright type checking.
- Terraform: follow existing module naming and keep inputs/outputs aligned with Terragrunt environment configs.

## Testing Guidelines

- There is no dedicated test suite in this repository. Use `ruff` and `pyright` as the minimum quality gate.
- If you add tests, document how to run them and place them under a `tests/` directory.

## Commit & Pull Request Guidelines

- Recent history uses short, imperative messages; dependency updates commonly follow `Bump <dep> from <old> to <new>`.
- Keep commits focused and avoid bundling infrastructure and app changes unless necessary.
- For PRs, include a clear description, the affected environment (`envs/dev/` or others), and any relevant plan output or screenshots (for UI changes).

## Security & Configuration Tips

- Keep AWS credentials in `~/.aws/credentials` and avoid committing secrets.
- Validate changes with `terragrunt run-all plan` before applying, especially for shared resources.

## Code Design Principles

Follow Robert C. Martin's SOLID and Clean Code principles:

### SOLID Principles

1. **SRP (Single Responsibility)**: One reason to change per class; separate concerns (e.g., storage vs formatting vs calculation)
2. **OCP (Open/Closed)**: Open for extension, closed for modification; use polymorphism over if/else chains
3. **LSP (Liskov Substitution)**: Subtypes must be substitutable for base types without breaking expectations
4. **ISP (Interface Segregation)**: Many specific interfaces over one general; no forced unused dependencies
5. **DIP (Dependency Inversion)**: Depend on abstractions, not concretions; inject dependencies

### Clean Code Practices

- **Naming**: Intention-revealing, pronounceable, searchable names (`daysSinceLastUpdate` not `d`)
- **Functions**: Small, single-task, verb names, 0-3 args, extract complex logic
- **Classes**: Follow SRP, high cohesion, descriptive names
- **Error Handling**: Exceptions over error codes, no null returns, provide context, try-catch-finally first
- **Testing**: TDD, one assertion/test, FIRST principles (Fast, Independent, Repeatable, Self-validating, Timely), Arrange-Act-Assert pattern
- **Code Organization**: Variables near usage, instance vars at top, public then private functions, conceptual affinity
- **Comments**: Self-documenting code preferred, explain "why" not "what", delete commented code
- **Formatting**: Consistent, vertical separation, 88-char limit, team rules override preferences
- **General**: DRY, KISS, YAGNI, Boy Scout Rule, fail fast

## Development Methodology

Follow Martin Fowler's Refactoring, Kent Beck's Tidy Code, and t_wada's TDD principles:

### Core Philosophy

- **Small, safe changes**: Tiny, reversible, testable modifications
- **Separate concerns**: Never mix features with refactoring
- **Test-driven**: Tests provide safety and drive design
- **Economic**: Only refactor when it aids immediate work

### TDD Cycle

1. **Red** → Write failing test
2. **Green** → Minimum code to pass
3. **Refactor** → Clean without changing behavior
4. **Commit** → Separate commits for features vs refactoring

### Practices

- **Before**: Create TODOs, ensure coverage, identify code smells
- **During**: Test-first, small steps, frequent tests, two hats rule
- **Refactoring**: Extract function/variable, rename, guard clauses, remove dead code, normalize symmetries
- **TDD Strategies**: Fake it, obvious implementation, triangulation

### When to Apply

- Rule of Three (3rd duplication)
- Preparatory (before features)
- Comprehension (as understanding grows)
- Opportunistic (daily improvements)

### Key Rules

- One assertion per test
- Separate refactoring commits
- Delete redundant tests
- Human-readable code first

> "Make the change easy, then make the easy change." - Kent Beck
