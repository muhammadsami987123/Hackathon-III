# Tasks: Environment Setup Guide

**Input**: Design documents from `/specs/003-env-setup-guide/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Tests**: Manual validation tasks included per platform (no automated tests for documentation)

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

Documentation deliverables located in `docs/environment-setup/` directory structure per plan.md

---

## Phase 1: Setup (Documentation Infrastructure)

**Purpose**: Create directory structure and shared documentation assets

- [x] T001 Create docs/environment-setup/ directory structure
- [x] T002 [P] Create docs/environment-setup/scripts/ directory for verification script
- [x] T003 [P] Set up Markdown linting configuration (optional - skipped)

**Checkpoint**: Directory structure ready for content creation

---

## Phase 2: Foundational (Shared Documentation)

**Purpose**: Core documentation that ALL user stories reference or depend on

**⚠️ CRITICAL**: Complete before platform-specific guides

- [x] T004 Create docs/environment-setup/README.md with TOC, overview, time estimates, system requirements table, and platform navigation
- [x] T005 [P] Create docs/environment-setup/prerequisites.md with git installation instructions and system requirements verification
- [x] T006 [P] Create docs/environment-setup/verification.md with post-installation validation procedures

**Checkpoint**: Foundation docs ready - platform guides can now be developed in parallel

---

## Phase 3: User Story 1 - Complete Environment Setup (Priority: P1) 🎯 MVP

**Goal**: Developer can install all 7 required tools (Docker, Minikube, kubectl, Helm, Claude Code, Goose, Git) on their platform and verify success

**Independent Test**: Follow guide on clean machine, run verification script, all checks pass. Estimated completion times: macOS 20 min, Linux 30 min, Windows WSL 35 min.

### User Story 4 Integration: Platform-Specific Guides

**Note**: User Story 4 (Platform-Specific Setup, Priority P2) is implemented within US1 since platform guides ARE the complete environment setup deliverable. US4 acceptance scenarios validate that each platform guide is self-contained and platform-appropriate.

### Implementation for User Story 1 & 4 (Combined)

- [x] T007 [P] [US1] Create docs/environment-setup/macos-installation.md following contracts/platform-guide-template.md (covers all 7 tools, checkpoint pattern, low-resource alternatives, proxy section)
- [x] T008 [P] [US1] Create docs/environment-setup/linux-installation.md following contracts/platform-guide-template.md (covers all 7 tools, checkpoint pattern, apt-get commands, low-resource alternatives)
- [x] T009 [P] [US1] Create docs/environment-setup/windows-wsl-installation.md following contracts/platform-guide-template.md (covers WSL 2 setup, all 7 tools, Docker Desktop integration, checkpoint pattern)
- [x] T010 [US1] Implement docs/environment-setup/scripts/verify-environment.sh following contracts/verification-script-spec.md (checks all 7 tools, detailed diagnostics, platform-specific remediation, colored output, exit codes)

**Checkpoint**: At this point, User Story 1 should be fully functional - developers can set up environment on any of 3 platforms and verify success

---

## Phase 4: User Story 2 - Repository Initialization (Priority: P2)

**Goal**: Developer can create skills-library and learnflow-app repository structures with correct directory layout and git initialization

**Independent Test**: Follow repository-setup.md instructions, verify directory structure with verification commands, confirm .claude/skills and git initialization

### Implementation for User Story 2

- [x] T011 [US2] Create docs/environment-setup/repository-setup.md with skills-library creation instructions (mkdir, .claude/skills directory, git init, initial commit, structure verification)
- [x] T012 [US2] Add learnflow-app creation instructions to repository-setup.md (mkdir, src/k8s directories, git init, initial commit, structure verification)
- [x] T013 [US2] Add repository structure verification commands to repository-setup.md (check directories exist, verify git initialization, validate README files)

**Checkpoint**: At this point, User Story 2 is complete - developers can initialize both required repositories with correct structure

---

## Phase 5: User Story 3 - Troubleshooting Common Issues (Priority: P3)

**Goal**: Developer encountering installation problems can diagnose and fix issues using troubleshooting guide

**Independent Test**: Deliberately break components (stop Docker, delete Minikube cluster, invalidate auth), verify troubleshooting steps restore functionality

### Implementation for User Story 3

- [x] T014 [P] [US3] Create docs/environment-setup/troubleshooting.md with Docker troubleshooting section (won't start, connection refused, platform-specific solutions)
- [x] T015 [P] [US3] Add Minikube troubleshooting section to troubleshooting.md (DRV_NOT_HEALTHY, insufficient disk space, version conflicts, platform-specific solutions)
- [x] T016 [P] [US3] Add kubectl troubleshooting section to troubleshooting.md (connection refused, context issues, version skew, solutions)
- [x] T017 [P] [US3] Add Claude Code and Goose authentication troubleshooting to troubleshooting.md (auth failures, re-authentication steps, browser flow issues)
- [x] T018 [P] [US3] Add general troubleshooting section (proxy issues, version conflicts, low-resource problems, recovery from mid-install failures)

**Checkpoint**: At this point, User Story 3 is complete - comprehensive troubleshooting guide covers 80%+ common problems (SC-006)

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, consistency checks, and documentation refinement

- [x] T019 [P] Review all platform guides for consistency in structure and terminology
- [x] T020 [P] Verify all internal links work (README → platform guides, guides → troubleshooting)
- [x] T021 [P] Validate checkpoint verification commands in all platform guides (test verify-before and verify-after patterns)
- [ ] T022 Test macOS installation guide on clean macOS system, validate 20-minute target (SC-001)
- [ ] T023 Test Linux installation guide on clean Ubuntu/Debian system, validate 30-minute target (SC-002)
- [ ] T024 Test Windows WSL installation guide on clean Windows system, validate 35-minute target (SC-003)
- [ ] T025 Test verification script on all 3 platforms (macOS, Linux, Windows WSL), validate detailed diagnostic output (SC-004)
- [ ] T026 Test repository-setup.md on all 3 platforms, validate structure verification commands (SC-007)
- [ ] T027 Validate low-resource configurations (2 CPU/4GB) on VM or limited hardware (SC-010)
- [ ] T028 Test troubleshooting guide solutions for common problems, validate 80%+ resolution rate (SC-006)
- [x] T029 Final review: Ensure all 17 functional requirements (FR-001 through FR-017) are satisfied
- [x] T030 Final review: Ensure all 10 success criteria (SC-001 through SC-010) are verifiable

**Checkpoint**: Documentation complete, tested, and ready for Hackathon III participants

---

## Dependencies

### User Story Completion Order

```
Phase 1 (Setup) → Phase 2 (Foundational)
                      ↓
                Phase 3 (US1 + US4 - Complete Setup)
                      ↓
                  ┌───┴───┐
                  ↓       ↓
         Phase 4 (US2)  Phase 5 (US3)
                  └───┬───┘
                      ↓
              Phase 6 (Polish)
```

**Critical Path**: Phase 1 → Phase 2 → Phase 3 (US1) → Phase 6 (Testing)

**Parallel Opportunities**:
- Phase 3: T007, T008, T009 (3 platform guides can be written in parallel)
- Phase 3: T010 (verification script) can be developed in parallel with platform guides
- Phase 4: T011, T012, T013 (US2 repository setup) independent of US3
- Phase 5: T014, T015, T016, T017, T018 (US3 troubleshooting sections) can be written in parallel
- Phase 6: T019, T020, T021 (reviews) can be done in parallel; T022-T028 (platform testing) must be sequential

### MVP Scope

**Minimum Viable Product (MVP)**: Phase 1 + Phase 2 + Phase 3 (User Story 1 + 4)

**Rationale**: US1 (Complete Environment Setup) includes platform-specific guides (US4) and is the foundation for all hackathon work. Developers can participate with just this scope - repository setup (US2) and troubleshooting (US3) enhance experience but aren't blocking.

**MVP Deliverables**:
- README.md (navigation)
- prerequisites.md
- 3 platform installation guides (macOS, Linux, Windows WSL)
- verification.md
- verify-environment.sh script

**Post-MVP Enhancements**:
- US2: Repository initialization guide
- US3: Comprehensive troubleshooting guide

---

## Parallel Execution Examples

### Scenario 1: Solo Developer

**Week 1**:
- Day 1: Phase 1 + Phase 2 (T001-T006) - Foundation
- Day 2-3: Phase 3 US1 (T007-T010) - Core guides + script
- Day 4: Phase 4 US2 (T011-T013) - Repository setup
- Day 5: Phase 5 US3 (T014-T018) - Troubleshooting

**Week 2**:
- Day 1-3: Phase 6 (T019-T030) - Testing and validation
- Day 4-5: Refinement and final polish

### Scenario 2: Team of 3 Developers

**Parallel Track A** (Dev 1):
- Phase 1 + Phase 2 (T001-T006)
- Phase 3: macOS guide (T007)
- Phase 4: Repository setup (T011-T013)
- Phase 6: macOS testing (T022, T025, T026)

**Parallel Track B** (Dev 2):
- Phase 3: Linux guide (T008)
- Phase 5: Troubleshooting Docker/Minikube (T014, T015)
- Phase 6: Linux testing (T023, T025, T026)

**Parallel Track C** (Dev 3):
- Phase 3: Windows WSL guide + verification script (T009, T010)
- Phase 5: Troubleshooting kubectl/auth (T016, T017, T018)
- Phase 6: Windows testing (T024, T025, T026)

**Shared** (All 3):
- Phase 6: Final reviews (T019-T021), low-resource testing (T027-T030)

**Timeline**: ~1 week with 3 developers vs. ~2 weeks solo

---

## Implementation Strategy

### Incremental Delivery

1. **Sprint 1 (MVP)**: Phase 1 + Phase 2 + Phase 3 (US1 + US4)
   - Deliverable: Complete environment setup guides for all 3 platforms with verification
   - Value: Developers can start hackathon work immediately

2. **Sprint 2**: Phase 4 (US2)
   - Deliverable: Repository initialization guide
   - Value: Streamlined repo setup for skills-library and learnflow-app

3. **Sprint 3**: Phase 5 (US3)
   - Deliverable: Comprehensive troubleshooting guide
   - Value: Reduced support burden, faster issue resolution

4. **Sprint 4**: Phase 6 (Polish)
   - Deliverable: Tested, validated, polished documentation
   - Value: High-quality onboarding experience

### Quality Gates

**After Phase 3 (US1 MVP)**:
- All 3 platform guides complete
- Verification script functional on all platforms
- Manual test on at least 1 platform successful
- **Go/No-Go Decision**: Ready for limited rollout?

**After Phase 6 (Polish)**:
- All 17 functional requirements verified
- All 10 success criteria met
- Time targets validated on all 3 platforms
- Troubleshooting covers 80%+ common issues
- **Final Release**: Ready for all Hackathon III participants

---

## Task Summary

**Total Tasks**: 30
- Phase 1 (Setup): 3 tasks
- Phase 2 (Foundational): 3 tasks
- Phase 3 (US1 + US4 - Complete Setup): 4 tasks (includes platform guides + verification script)
- Phase 4 (US2 - Repository Initialization): 3 tasks
- Phase 5 (US3 - Troubleshooting): 5 tasks
- Phase 6 (Polish & Testing): 12 tasks

**Parallel Opportunities**: 15 tasks marked [P] can be executed in parallel

**Tasks by User Story**:
- US1 (Complete Environment Setup) + US4 (Platform-Specific): 4 tasks (T007-T010)
- US2 (Repository Initialization): 3 tasks (T011-T013)
- US3 (Troubleshooting): 5 tasks (T014-T018)
- Setup/Foundational: 6 tasks (T001-T006)
- Polish/Validation: 12 tasks (T019-T030)

**MVP Scope**: 10 tasks (T001-T010) - Phases 1-3

**Estimated Effort**:
- Solo developer: ~2 weeks (10 days)
- Team of 3: ~1 week (5 days)
- MVP only: ~1 week solo, ~3 days with team

---

## Format Validation

✅ All tasks follow checklist format: `- [ ] [TID] [P?] [Story?] Description with file path`
✅ Task IDs sequential (T001-T030)
✅ Parallel markers ([P]) applied to 15 independent tasks
✅ Story labels ([US1], [US2], [US3]) applied to 12 user story tasks
✅ File paths included in all implementation tasks
✅ Dependencies clearly mapped in dependency graph
✅ MVP scope explicitly defined (Phases 1-3)
✅ Parallel execution examples provided
✅ Independent test criteria defined for each user story

**Tasks.md generation complete and validated** ✅
