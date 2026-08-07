# 🔥 تفعيل Firebase (مجاني 100%)

## الخطوات:

### 1. سجّل دخول على Firebase
```
firebase login
```

### 2. فعّل الـ Spark Plan (مجاني)
```
firebase projects:create lexi-language-app
```

### 3. أضف خدمات Firebase المطلوبة:
- **Firestore Database** - للمنهج وبيانات المستخدمين
- **Authentication** - لتسجيل الدخول
- **Storage** - للملفات والصور
- **Hosting** - للموقع (اختياري)

### 4. أضف Firebase للتطبيق:
```
flutterfire configure --project=lexi-language-app
```

### 5. فعّل الخدمات من الكونسول:
https://console.firebase.google.com/

---

## حدود الـ Spark Plan (مجاني):

| الخدمة | الحد المجاني |
|--------|-------------|
| Firestore | 1 GB تخزين، 50K قراءة/يوم |
| Auth | 10K مستخدم/شهر |
| Storage | 5 GB |
| Hosting | 10 GB |
| Functions | 2M استدعاء/شهر |

**مفيش كارت إئتمان مطلوب!**

---

## البدائل المجانية لو Firebase مش مناسب:

### 1. Supabase (مفتوح المصدر)
- 500 MB قاعدة بيانات
- 1 GB تخزين ملفات
- 50K مستخدم

### 2. MongoDB Atlas
- 512 MB تخزين مجاني

### 3. Railway/Render
- استضافة backend مجانية
