# Vehiculum

**My app for collecting car photos**

## What is this project?
Vehiculum is an iOS app I created to learn native iOS development. The idea is simple: photograph the cars you see around and create your own personal digital collection.
It's like Instagram but only for cars you like - you photograph them, add the brand and model, and everything gets saved automatically on your phone (and on iCloud if you want).

##  How I got the idea💡
I was inspired to create this app by an existing app on the App Store called **"CarSpotter"**. I really liked the concept of the app, especially because I was already taking photos of cars and putting them in an album, manually writing down the brand and model. Finding this app made everything simpler. 
Another feature I loved was the implementation of AI for recognizing the car's brand and model automatically. However, the negative side of that app was its very confusing and overwhelming UI - it felt cluttered and hard to navigate. 
So I decided to take the core concept and rebuild it from scratch, creating a cleaner, more intuitive version with a focus on simplicity and user experience. This project became both a way to improve on an idea I liked and a learning opportunity to master iOS development.

**Key improvements I wanted to make:**
- ✨ **Cleaner UI**: Simple, intuitive interface inspired by Apple's design language
- 🎯 **Better UX**: Smooth animations and clear navigation
- 📱 **Modern tech**: Built with SwiftUI and SwiftData instead of older frameworks
- 🚀 **Learning goals**: Understanding how AI recognition works (future feature with Create ML)

This is my take on the car collection app concept, rebuilt with modern iOS technologies and a focus on what I think makes a great user experience.

## What the app does
### Main features:
**📸 Photograph cars**
- You can take a photo directly from the app
- Or choose a photo you already have in your gallery
- When you add a photo, you enter the brand and model

**🏠 Homepage**
- See statistics: how many cars you have in your collection
- Buttons to photograph or choose from gallery
- A "Recent" section with the last 5 cars added (sorted by most recent)
- There's also an animation of a little car passing over the "Vehiculum" text at the beginning

**🗂️ Collection**
- See all your cars in a grid
- Each card shows the photo, brand and model
- Click on a card to see details

**✏️ Details and editing**
- See the large image of the car
- You can edit brand and model
- You can delete the car from the collection
- There's also the date of when you added it

**☁️ iCloud Sync**
- At the beginning of the app it asks if you want to enable iCloud
- If you enable it, your cars sync across all your Apple devices
- See sync status in real-time

## 🛠️ Technologies I used

### Apple frameworks:
**SwiftUI** - For the entire interface
I learned that SwiftUI is very different from UIKit. It's declarative: you describe WHAT you want to see, not HOW to build it step by step. At first it's weird but then it becomes natural.

**SwiftData** - For saving data
It's Apple's new framework for persistence (it replaced Core Data). It's much simpler! You define a `@Model` and SwiftData does all the dirty work.

**CloudKit** - For iCloud
This was the hardest part. Making data sync between devices isn't trivial, but I finally got it working (though I admit the sync is sometimes a bit temperamental).

**UIKit** (partial)
Even though I use SwiftUI, some things still come from UIKit:
- `UIImage` to handle images
- `UIImagePickerController` for camera and gallery
- `UIImpactFeedbackGenerator` for haptic feedback (that vibration when you press buttons)

**Foundation** - The foundation of everything
It's the framework that contains all the basic types: String, Array, Date, etc. You always use it even without realizing it.

### Architecture:
I used the **MVVM** pattern (Model-View-ViewModel):
- **Model**: The `Car` class with all the car data
- **View**: All the screens (Home, Collection, Detail)
- **ViewModel**: The `CarManager` that handles business logic


## 📚 What I learned
Here I learned:
The two main technologies I focused on learning were **Create ML** for AI model training and **CloudKit** for cloud synchronization.

### Create ML & AI Model Training
Training an AI model to recognize car brands and models was one of the most exciting parts of this project.

**The process:**
**Dataset preparation** - The hardest part
- Collected hundreds of car images for different brands and models
- Organized them into folders by category (each folder = one class)
- Made sure to have variety: different angles, lighting, backgrounds
- Split into training (80%) and validation (20%) sets

**Training the model**
- Used Create ML's visual interface - drag and drop images
- Experimented with data augmentation (rotation, flip, crop) to improve accuracy
- Started at ~60% accuracy, got it up to ~85% after optimization
- Compressed the model to keep app size small

**Integration**
- Imported the `.mlmodel` file into Xcode
- Used Vision framework to preprocess images before prediction
- Added confidence scores to show users how certain the AI is
- Handled edge cases (unknown cars, blurry photos)

**Key learnings:**
- Quality of training data matters more than quantity (garbage in, garbage out)
- On-device ML is incredibly fast (predictions in milliseconds)
- Balancing accuracy vs model size is important
- Similar-looking cars (BMW 3 Series vs 5 Series) are challenging for the model

### CloudKit & iCloud Synchronization
CloudKit was the most challenging part - powerful but complex with a steep learning curve.

**What I learned:**
**Basic architecture**
- Private database for user's personal data
- Records (like database rows) and Record Types (like schemas)
- CKAssets for storing large files like car images
- Understanding how to structure data for cloud storage

**Sync implementation**
```swift
// My sync flow:
1. User makes change (add/edit/delete car)
2. Update local SwiftData immediately (optimistic UI)
3. Create/update CloudKit record in background
4. Handle success or failure
5. Listen for changes from other devices
6. Merge remote changes into local database
```

**Major challenges:**
**Conflict resolution**
When the same car is edited on two devices:
- Implemented last-write-wins (simpler approach)
- Used CKRecord change tags to detect conflicts
- Had to handle merge scenarios

**Error handling**
CloudKit fails in many ways:
- No internet connection
- Not signed into iCloud
- Rate limiting (too many requests)
- Server errors
- Had to gracefully handle each scenario

**State management**
```swift
// Tracking sync states:
- isSyncing: Bool          // Currently syncing
- lastSyncDate: Date?      // Last successful sync
- syncError: String?       // Error messages for user
```

**Key learnings:**
- Cloud sync is harder than it looks - networks are unreliable
- Need to design for eventual consistency (data might not sync instantly)
- Optimistic updates make UI feel fast (show changes immediately, sync in background)
- Testing requires multiple devices and iCloud accounts
- CloudKit Dashboard is essential for debugging

**What surprised me:**
- Images as CKAssets need special handling (compression, download management)
- Subscriptions allow push notifications when data changes on other devices
- Background sync is tricky - need to handle app being closed
- Users expect sync to be invisible and "just work"

### The biggest takeaway:
Both technologies pushed me way out of my comfort zone:
- **Create ML** taught me that machine learning is accessible to app developers, not just data scientists
- **CloudKit** taught me that building reliable sync is complex - you have to think about network failures, conflicts, and user experience

The hardest part wasn't learning the APIs - it was understanding the *patterns* and *edge cases*.




