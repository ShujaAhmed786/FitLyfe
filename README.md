# Fit Lyfe | Smart Calorie & Nutrition Tracker ðŸ¥—ðŸ“Š

**Fit Lyfe** is a feature-rich, privacy-focused mobile application built with **Flutter** designed to make calorie tracking, meal planning, and health monitoring effortless, engaging, and lightning-fast. 

Whether your goal is to lose weight, build muscle, or maintain a balanced lifestyle, Fit Lyfe provides all the tools you need right on your device.

---

## Key Features

* **Calorie Tracker & Food Log:** Effortlessly log daily meals, snacks, and drinks with dynamic smart group emojis (automatically adapting for Breakfast, Lunch, Dinner, Protein, and Drinks) across your logs and screens.
* **Extensive Food Library:** Browse and search a robust database of food items powered by the USDA API to quickly find nutritional breakdowns and add your favorite meals.
* **Macro Counter:** Seamlessly monitor proteins, carbohydrates, and fats to stay precisely on target with your health and fitness goals.
* **Gamified Ranking System:** Stay motivated throughout your health journey by tracking your progress and leveling up through an engaging rank structure.
* **Daily Quick Tips:** Access bite-sized, actionable health, nutrition, and wellness tips right when you need them to build sustainable habits.
* **Persistent Undo & Local Backup:** Safeguard your data with local storage handling and a reliable 2-hour reset "undo" window that survives app restarts.
* **Built-in Feedback Mechanism:** Easily submit in-app feedback to help continuously improve the app experience.
* **Local Privacy First:** All personal health logs, custom meal lists, and user data remain stored securely right on your device.

---

## Tech Stack & Architecture

* **Framework:** Flutter & Dart
* **Data Management:** Local storage handling with robust state management and backup protocols
* **API Integration:** USDA API injected securely during builds via `--dart-define`
* **UI/UX:** Clean, distraction-free design with responsive layouts and dynamic visual indicators

---

## Getting Started (Development Setup)

To run this project locally, make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.

1. **Clone the repository:**
       ```bash
     git clone [https://github.com/your-username/fit-lyfe.git](https://github.com/your-username/fit-lyfe.git)
     cd fit-lyfe
     Run the app (injecting your USDA API key):
     flutter run --dart-define=USDA_API_KEY=your_actual_api_key_here
   
3. Install dependencies:
     flutter pub get

4. Build & Release
     To generate an optimized Android App Bundle (.aab) for testing or deployment:
     flutter build appbundle --dart-define=USDA_API_KEY=your_actual_api_key_here

---

## DevOps Deployment

This project is deployed on AWS with a full CI/CD pipeline.

### Architecture

![FitLyfe Deployment Flow](docs/screenshots/fitlyfe-deployment-flow.png)

### App Screenshots

### Add Meal
<img src="docs/screenshots/02-add-meal-enhanced.jpg" width="300" alt="Add Meal">

### My Meals
<img src="docs/screenshots/03-meals-list-enhanced.jpg" width="300" alt="My Meals">

### Activity Logs
<img src="docs/screenshots/04-activity-logs-enhanced.jpg" width="300" alt="Activity Logs">

### CI/CD Pipeline

GitHub Actions builds the Docker image, scans it with Trivy, and pushes to GHCR. ArgoCD syncs the manifests to the K3s cluster.

![CI Runs](docs/screenshots/ci-runs-list.png)

![CI Job Details](docs/screenshots/ci-job-details.png)

### Infrastructure

- **Cloud:** AWS (us-east-1)
- **Kubernetes:** K3s on EC2 (ARM64 Graviton)
- **Database:** PostgreSQL 14 + Redis
- **CI/CD:** GitHub Actions + ArgoCD GitOps
- **IaC:** Terraform
- **Access:** Cloudflare Tunnel