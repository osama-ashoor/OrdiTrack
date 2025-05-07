OrdiTrack 🛍️📱

OrdiTrack is a side admin app built to manage an online store page where customers place orders via messages. The app is exclusively used by the admin to add products, manage orders, and keep track of the entire process — from adding items to the cart to updating the order status.

⸻

Features ✨
	•	➕ Add Products: Title, price, description, and image upload.
	•	🛒 Manage Cart: Add products to a cart for each client request.
	•	🧾 Order Data Entry: Admin receives customer order via messages and fills in the details in the app.
	•	🔄 Update Order Status: Keep track of every order stage (e.g. Confirmed, Purchased, Shipped, Delivered).
	•	📱 Simple & Clean UI: Designed for quick and easy admin use.

⸻

Tech Stack 🧩
	•	Frontend: Flutter
	•	Database: Firebase Firestore
	•	Image Storage: Firebase Storage

⸻

Installation & Run 🚀

git clone https://github.com/osama-ashoor/OrdiTrack.git
cd OrdiTrack-App
flutter pub get
flutter run

Make sure you have Firebase configured and connected before running the app.

⸻

Order Status Flow 📦
	•	🕓 Under Review
	•	✅ Confirmed
	•	💳 Purchased
	•	🚚 Shipping
	•	📬 Delivered

Notes 📝
	•	This app is only for the admin managing the online page.
	•	Customers do not use the app — they send their order via social media or chat.
	•	All data is stored securely in Firestore, and product images are uploaded to Firebase Storage.
	•	Future features may include: sales reports, desktop dashboard, and push notifications.

License 📄

This project is for private use only. Not licensed for public distribution.

