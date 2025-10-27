# 🏢 AdminFlow – HR & Payroll Management System

AdminFlow is a modern HR & Payroll management system built using **Flutter + Firebase**.  
It allows administrators to manage employees, track salaries, generate payrolls, view analytics, and interact with an **AI HR Assistant** powered by **Gemini API**.

---

## ✨ Features

| Feature | Description |
|--------|-------------|
| 👤 Secure Admin Login | Firebase Authentication |
| 👨‍👨‍👨 Employee Management | Add, Edit, Remove, and List employees |
| 💰 Payroll Management | Base Salary + Bonuses + Deductions |
| 📊 Reports Dashboard | Salary analytics and charts |
| 🤖 AI HR Assistant | Execute HR actions using natural language |
| ⚡ï¸ Real-Time Sync | Cloud Firestore live updates |
| 🎨 Neumorphic UI | Smooth and modern interface |

---

## 🤓 AI Command Examples
```
Add employee Ali with salary 600 as accountant.
Increase Ahmed’s salary to 850.
Delete employee Sara.
Who has the highest salary?
List all employees.
```

---

## 🏣️ Firebase Firestore Structure
```
admins
└── adminId
    └── employees
        └── employeeId
            └── payrolls
                └── payrollId
```

---

## 📂 Project Structure
```
lib/
├─ core/
│  ├─ neumorphic_style.dart
│  └─ theme.dart
│
├─ models/
│  └─ employee.dart
│
├─ providers/
│  ├─ auth_provider.dart
│  └─ employee_provider.dart
│
├─ screens/
│  ├─ auth/
│  │  ├─ login_screen.dart
│  │  └─ signup_screen.dart
│  │
│  ├─ dashboard/
│  │  └─ dashboard_screen.dart
│  │
│  ├─ chat/
│  │  └─ ai_chat_screen.dart
│  │
│  ├─ employee/
│  │  ├─ add_employee_screen.dart
│  │  ├─ employee_detail_screen.dart
│  │  └─ employee_list_screen.dart
│  │
│  ├─ payroll/
│  │  └─ payroll_screen.dart
│  │
│  └─ reports/
│     └─ reports_screen.dart
│
├─ services/
│  ├─ auth_services.dart
│  ├─ employee_service.dart
│  └─ ai_chat_service.dart
│
├─ firebase_options.dart
└─ main.dart
```

---

## ▶️ Run the App
```
flutter pub get
flutter run
```

Add `.env`:
```
GEMINI_API_KEY=YOUR_KEY_HERE
```

---

## ⭐ Support
If you like this project, please **star ⭐** the repository.
