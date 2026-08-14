# AGENTS.md — LEXI Development Commands

## Project Structure
- `lingua_ai/` — Flutter frontend application
- `backend/` — NestJS + PostgreSQL backend API

---

## Flutter (Frontend)

### Lint / Static Analysis
```bash
flutter analyze
```

### Run Tests
```bash
flutter test
```

### Run App (Debug)
```bash
flutter run
```

### Build APK (Release)
```bash
flutter build apk --release --build-number=1 --build-name=1.0.0
```

### Build App Bundle (Play Store)
```bash
flutter build appbundle --release
```

### Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Backend (NestJS)

### Install Dependencies
```bash
cd backend && npm install
```

### Lint
```bash
cd backend && npm run lint
```

### Build
```bash
cd backend && npm run build
```

### Start (Development)
```bash
cd backend && npm run start:dev
```

### Start (Production)
```bash
cd backend && npm run start:prod
```

### Tests
```bash
cd backend && npm test
```

### E2E Tests
```bash
cd backend && npm run test:e2e
```

### Database Migration
```bash
cd backend && npx prisma migrate dev --name <migration_name>
```

### Database Push (Schema-only, no migration)
```bash
cd backend && npm run prisma:push
```

### Seed Database
```bash
cd backend && npm run seed
```

### Prisma Studio
```bash
cd backend && npm run prisma:studio
```

### Generate Prisma Client
```bash
cd backend && npm run prisma:generate
```

---

## Common Workflows

### Full Stack Development
```bash
# Terminal 1: Backend
cd backend && npm run start:dev

# Terminal 2: Flutter
flutter run
```

### Android Release Build
```bash
# 1. Build backend
cd backend && npm run build

# 2. Set production env
cp backend/.env.production backend/.env

# 3. Build Flutter release
flutter build apk --release --flavor production
```

---

## Key Architecture Notes

- **Backend is authoritative** for: XP, level, streak, lesson completion, exam scores, progress, achievements, store ownership.
- **Frontend displays** backend truth only — no client-side XP/streak/level calculation.
- **Firebase Auth** is used for authentication; the backend exchanges Firebase tokens for JWTs and creates PostgreSQL users (with CUID) automatically.
- **Curriculum** is stored in PostgreSQL via Prisma. Seed data comes from `assets/data/curriculum_a1.json` and is loaded by `backend/prisma/seed.ts`.
- **No fake/demo data** in production flows. All features must show loading/empty/error states.
