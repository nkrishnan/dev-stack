# Stack Change Process

Use this process when proposing changes to the dev-stack toolchain, templates, or conventions.

## Steps

1. **Spec**: Write a decision doc in `docs/decisions/` following the spec-kit format.
2. **Branch**: Create a feature branch from `main`.
3. **Implementation**: Make changes and add or update tests.
4. **CI**: Ensure all CI checks pass.
5. **PR**: Open a pull request referencing the decision doc.
6. **Review**: Get at least one approval.
7. **Merge**: Squash-merge to `main`.
8. **Profile promotion**: If the change affects a profile, update `profiles/stable/` or `profiles/experimental/` as appropriate.
