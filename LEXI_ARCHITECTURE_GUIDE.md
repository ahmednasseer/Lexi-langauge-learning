# LEXI ARCHITECTURE GUIDE

## 1. VISION

### هدف المشروع
تطبيق تعليم اللغة الألمانية بالذكاء الاصطناعي يوفر تجربة تعلم شخصية وممتعة.

### المستخدم المستهدف
- المبتدئون في تعلم اللغة الألمانية (A1-B1)
- الطلاب الذين يحضرون لامتحانات غوته
- المغتربون في ألمانيا

### المبادئ الأساسية
- **Simplicity First**: بساطة قبل التعقيد
- **User First**: المستخدم أولاً
- **Incremental Development**: تطوير تدريجي
- **Test Before Ship**: اختبار قبل إطلاق
- **No Mock in Production**: ممنوع البيانات الوهمية في الإنتاج

---

## 2. ARCHITECTURE

### Pattern: Feature First + Clean Architecture

```
lib/
├── core/
│   ├── di/                    # Dependency Injection
│   ├── error/                 # Error Handling
│   ├── logger/                # Logging
│   ├── network/               # Network Layer
│   ├── services/              # Core Services (shared across all features)
│   ├── storage/               # Local Storage
│   └── utils/                 # Utilities
├── shared/
│   ├── models/                # Shared Models
│   ├── providers/             # Shared Providers
│   └── widgets/               # Shared Widgets
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/   # Remote/Local Data Sources
│   │   │   ├── models/        # Data Models (DTOs)
│   │   │   └── repositories/  # Repository Implementations
│   │   ├── domain/
│   │   │   ├── entities/      # Business Entities
│   │   │   ├── repositories/  # Repository Interfaces
│   │   │   └── usecases/      # Business Logic
│   │   ├── presentation/
│   │   │   ├── bloc/          # Blocs/Cubits
│   │   │   ├── screens/       # Screens
│   │   │   └── widgets/       # Feature Widgets
│   │   └── README.md          # Feature Documentation
│   └── .../
└── main.dart
```

### قواعد الـ Architecture:

1. **Feature First**: كل Feature مستقل بذاته
2. **لا اعتماد مباشر**: ممنوع Feature تستورد من Feature تانية
3. **التواصل عبر**: Repository Interface, Core Services, Shared Components
4. **كل Feature تحتوي على README.md** يشرح الهدف والـ Dependencies

---

## 2.1. Feature README Template

كل Feature يجب أن تحتوي على `README.md`:

```markdown
# Feature Name

## Purpose
وصف الهدف من الـ Feature

## Dependencies
- Features تعتمد عليها
- Core Services مستخدمة
- Shared Components

## Firebase Collections
- كل Collections مستخدمة

## Routes
- كل الـ Routes

## State Management
- Blocs/Cubits مستخدمة

## Public API
- ما يمكن استخدامه من Features أخرى
```

---

## 2.2. Core Services

الخدمات العامة المشتركة بين كل الـ Features:

| Service | Path |
|---------|------|
| AuthService | core/services/ |
| StorageService | core/services/ |
| NotificationService | core/services/ |
| AnalyticsService | core/services/ |
| ConnectivityService | core/services/ |
| ApiService | core/services/ |

### طبقات المشروع

| Layer | Responsibility |
|-------|----------------|
| Core | Shared services, DI, utils |
| Shared | Shared widgets, models, providers |
| Features | Each feature has data/domain/presentation |

### قواعد النقل بين الطبقات
- **مسموح**: Features ← Core, Features ← Shared
- **ممنوع**: Features ← Features (مباشر)
- **ممنوع**: Core ← Features
- **التواصل**: عبر Repository Interface أو Core Services

---

## 3. STATE MANAGEMENT

### System: flutter_bloc (Bloc/Cubit)

#### القواعد:
- استخدام **Cubit** للحالات البسيطة
- استخدام **Bloc** للحالات المعقدة مع Events
- كل Screen لها Bloc/Cubit خاص
- لا يوجد Bloc عام لأكثر من 3 Screens

#### دورة الحياة:
- **الإنشاء**: عند فتح الشاشة (BlocProvider create)
- **التخلص**: عند إغلاق الشاشة (تلقائي via BlocProvider)
- **التجديد**: عند الحاجة (BlocProvider.value)

#### تحديث الواجهة:
- `emit(newState)` فقط
- لا setState داخل BlocBuilder
- Equatable لجميع States

---

## 3. STATE MANAGEMENT

### System: flutter_bloc (Bloc/Cubit)

#### القواعد:
- استخدام **Cubit** للحالات البسيطة
- استخدام **Bloc** للحالات المعقدة مع Events
- كل Screen لها Bloc/Cubit خاص
- لا يوجد Bloc عام لأكثر من 3 Screens

#### دورة الحياة:
- **الإنشاء**: عند فتح الشاشة (BlocProvider create)
- **التخلص**: عند إغلاق الشاشة (تلقائي via BlocProvider)
- **التجديد**: عند الحاجة (BlocProvider.value)

#### تحديث الواجهة:
- `emit(newState)` فقط
- لا setState داخل BlocBuilder
- Equatable لجميع States

---

## 4. DEPENDENCY INJECTION

### System: get_it + injectable

#### الأنواع:
| Type | Usage |
|------|-------|
| Singleton | Services, Repositories |
| Lazy Singleton | Database, Firebase instances |
| Factory | Blocs, UseCases |

#### القواعد:
- التسجيل في `injection_container.dart`
- لا new مباشرة أبدًا
- كل شيء عبر GetIt.instance
- `@injectable` annotation لكل الكلاسات

---

## 5. REPOSITORY PATTERN

### الهيكل الرسمي:

```dart
// Interface (Domain Layer)
abstract class UserRepository {
  Future<User> getUser(String id);
  Future<void> updateUser(User user);
}

// Implementation (Data Layer)
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remote;
  final UserLocalDataSource _local;
  
  @override
  Future<User> getUser(String id) async {
    try {
      final user = await _remote.getUser(id);
      await _local.cacheUser(user);
      return user;
    } catch (e) {
      return _local.getCachedUser(id);
    }
  }
}
```

### المصادر:
- **Remote**: Firestore, Firebase Auth, APIs
- **Local**: SharedPreferences, Hive, SQLite

### القواعد:
- Repository يبدأ بـ Remote
- يفشل → يعود إلى Local
- ينجح → يخزن في Local

---

## 6. BACKEND RULES

### Firebase Collections:

```
users/{userId}                 # بيانات المستخدم
users/{userId}/progress        # التقدم
users/{userId}/inventory       # المخزون

curriculum/{level}/units/{unitId}/lessons/{lessonId}
questions/{level}/questions/{questionId}
audio/{audioId}
pronunciation/{pronunciationId}
speaking/{exerciseId}

posts/{postId}
posts/{postId}/comments/{commentId}
posts/{postId}/likes/{userId}

friends/{userId}/friends/{friendId}
messages/{conversationId}/messages/{messageId}

store/{itemId}
inventory/{userId}/items/{itemId}

achievements/{achievementId}
missions/{missionId}
streaks/{userId}
quests/{questId}
leaderboard/{period}

events/{eventId}
rooms/{roomId}

notifications/{userId}/notifications/{notifId}
```

### Security Rules:
```javascript
// Firestore
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}

match /posts/{postId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.uid == resource.data.authorId;
}
```

---

## 7. UI RULES

### Design System:
- **Theme**: Dark/Light مع Material 3
- **Typography**: Poppins (Google Fonts)
- **Colors**: معرفة في AppColors
- **Icons**: Material Icons

### الحالات:
| State | Widget |
|-------|--------|
| Loading | Skeleton/CircularProgressIndicator |
| Empty | EmptyState مع رسالة وإجراء |
| Error | ErrorState مع Retry |
| Success | المحتوى الفعلي |

### الأنيميشن:
- استخدام flutter_animate
- Duration: 200-400ms
- لا أنيميشنات ثقيلة

---

## 8. NAVIGATION RULES

### System: Named Routes

### Route Naming:
```
/auth/login
/auth/register
/auth/forgot-password
/home
/profile
/profile/edit
/lessons
/lessons/{lessonId}
/quiz/{quizId}
/store
/store/inventory
/community
/chat/{userId}
/settings
```

### Guards:
```dart
RouteGuard(
  requiresAuth: ['/home', '/profile', '/lessons'],
  requiresGuest: ['/auth/login', '/auth/register'],
);
```

---

## 9. ASSETS RULES

### الهيكل:
```
assets/
├── images/
│   ├── logo.png
│   ├── characters/
│   ├── badges/
│   ├── frames/
│   └── backgrounds/
├── audio/
│   └── lessons/
└── lottie/
```

### Naming:
- أسماء صغيرة مع underscore
- مثال: `lexi_happy.png`, `badge_a1.png`

### Optimization:
- WebP للصور
- Compression: 80%
- Max size: 500KB per image

---

## 10. ERROR HANDLING

### الأنواع:
```dart
abstract class Failure {}
class NetworkFailure extends Failure {}
class FirebaseFailure extends Failure {}
class ValidationFailure extends Failure {}
class UnknownFailure extends Failure {}
```

### القواعد:
- كل Repository يعيد `Either<Failure, Success>`
- لا try-catch في UI
- Bloc يلتقط الأخطاء ويحولها لـ State
- رسالة خطأ واضحة للمستخدم

---

## 11. LOGGING

### القواعد:
| Level | Usage |
|-------|-------|
| Debug | Development only |
| Info | User actions, Navigation |
| Warning | Deprecated API, Slow operations |
| Error | Failures, Exceptions |

### الاستخدام:
```dart
AppLogger.d('Debug message');
AppLogger.i('User logged in: $userId');
AppLogger.w('Slow operation detected');
AppLogger.e('Error occurred', error, stackTrace);
```

---

## 12. PERFORMANCE RULES

### Pagination:
```dart
// Firestore
collection
  .orderBy('createdAt')
  .limit(20)
  .startAfterDocument(lastDocument);
```

### Lazy Loading:
- ListView.builder دائمًا
- لا shrinkWrap إلا للضرورة
- addAutomaticKeepAlives: false

### Image Cache:
- cached_network_image package
- Max age: 7 days
- Max size: 100MB

### Rebuild Rules:
- const constructors
- RepaintBoundary للودجات المتحركة
- لا setState في build

---

## 13. SECURITY RULES

### Authentication:
- Firebase Auth إلزامي
- Token refresh تلقائي
- Session timeout: 30 days

### Input Validation:
```dart
// جميع المدخلات تُحقق
final emailValidator = EmailValidator();
final passwordValidator = PasswordValidator(minLength: 8);
```

### Secure Storage:
- flutter_secure_storage للـ Tokens
- لا تخزين بيانات حساسة في SharedPreferences

### API Keys:
- في متغيرات البيئة فقط
- لا في الكود أبدًا
- --dart-define للقيم المختلفة

---

## 14. TESTING STRATEGY

### الحدود الأدنى:

| Type | Coverage | Required Before Merge |
|------|----------|----------------------|
| Unit Tests | 70% | Yes |
| Widget Tests | 50% | Yes |
| Integration Tests | Critical paths | Yes |

### Unit Tests:
```dart
// لكل UseCase
// لكل Repository
// لكل Bloc
test('should return user when data exists', () async {
  // arrange
  // act
  // assert
});
```

### Widget Tests:
```dart
// لكل Screen رئيسية
testWidgets('should show loading initially', (tester) async {
  // pumpWidget
  // expect CircularProgressIndicator
});
```

---

## 15. CODING STANDARDS

### Naming:
| Type | Convention | Example |
|------|------------|---------|
| Class | PascalCase | UserRepository |
| Method | camelCase | getUser |
| Variable | camelCase | userName |
| Constant | UPPER_SNAKE_CASE | MAX_RETRIES |
| File | snake_case | user_repository.dart |
| Folder | snake_case | user_management |

### القواعد:
- كل Class في ملف منفصل
- لا ملفات تتجاوز 300 سطر
- كل Method لا يتجاوز 30 سطر
- تعليق لكل Public API

### Comments:
```dart
/// Fetches user by ID
/// Throws [UserNotFoundException] if user doesn't exist
Future<User> getUser(String id) async {
  // implementation
}
```

---

## 16. GIT WORKFLOW

### Branch Strategy:
- `main`: Production-ready
- `develop`: Integration
- `feature/TASK-xxx`: New features
- `fix/TASK-xxx`: Bug fixes

### Commit Convention:
```
feat(TASK-001): add user authentication
fix(TASK-002): resolve login crash
refactor(TASK-003): optimize repository pattern
test(TASK-004): add user bloc tests
docs(TASK-005): update architecture guide
```

### Pull Request:
- Minimum 1 reviewer
- All tests pass
- No merge conflicts
- Code reviewed

---

## 17. DEFINITION OF DONE

لا تعتبر أي Task منتهية إلا إذا:

- [ ] تعمل بالكامل
- [ ] جميع التبعيات مكتملة
- [ ] لا يوجد TODO
- [ ] لا يوجد Mock Data
- [ ] لا يوجد Dead Code
- [ ] لا يوجد Warning
- [ ] لا يوجد Error
- [ ] Unit Tests مكتوبة
- [ ] Widget Tests مكتوبة (للشاشات)
- [ ] تمت مراجعة الكود
- [ ] تم اختبارها يدويًا
- [ ] تم تحديث الوثائق إذا لزم الأمر
- [ ] PR approved
- [ ] Merged to develop

---

## CONFLICTS RESOLVED

| Conflict | Resolution | Reason |
|----------|------------|--------|
| State Management | Bloc over Riverpod | Better tooling, clearer separation |
| DI | GetIt over Riverpod DI | Simpler, faster compilation |
| Storage | Hive over SQLite | Faster, simpler API |
| Navigation | Named Routes over GoRouter | Simpler, sufficient for current needs |

---

# END OF ARCHITECTURE GUIDE
