# Firestore Security Rules

## Overview

SpeakingNotes uses two top-level Firestore collections: `categories` and `notes`. Every document in both collections carries a `userId` field set to the authenticated user's UID at write time (see `FirebaseCategoryRepository` and `FirebaseNoteRepository`). The security rules enforce that a user can only read and write their own documents — no cross-user data access is possible at the database level, regardless of what the client sends.

## Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper: request comes from a signed-in user
    function isAuthenticated() {
      return request.auth != null;
    }

    // Helper: the document's userId field matches the caller's UID
    function isOwner() {
      return resource.data.userId == request.auth.uid;
    }

    // Helper: the userId field being written matches the caller's UID
    function isWritingAsOwner() {
      return request.resource.data.userId == request.auth.uid;
    }

    match /categories/{categoryId} {
      // Only the owner can read their own categories
      allow read: if isAuthenticated() && isOwner();

      // Only authenticated users can create; userId must equal their own UID
      allow create: if isAuthenticated() && isWritingAsOwner();

      // Only the owner can update or delete
      allow update, delete: if isAuthenticated() && isOwner();
    }

    match /notes/{noteId} {
      // Only the owner can read their own notes
      allow read: if isAuthenticated() && isOwner();

      // Only authenticated users can create; userId must equal their own UID
      allow create: if isAuthenticated() && isWritingAsOwner();

      // Only the owner can update or delete
      allow update, delete: if isAuthenticated() && isOwner();
    }
  }
}
```

## Rule-by-rule explanation

### `isAuthenticated()`
Checks that `request.auth != null` — rejects all unauthenticated requests before any collection-level rule is evaluated. Anonymous or signed-out clients cannot touch any document.

### `isOwner()`
Compares the **existing** document's `userId` field against the caller's Firebase Auth UID (`request.auth.uid`). Used on `read`, `update`, and `delete` so that a user cannot access, modify, or delete another user's documents even if they know the document ID.

### `isWritingAsOwner()`
Compares the **incoming** document's `userId` field (`request.resource.data.userId`) against the caller's UID. Used on `create` to prevent a client from forging a document with someone else's `userId`.

### `/categories/{categoryId}`

| Operation | Rule | Reason |
|-----------|------|--------|
| `read` | `isAuthenticated() && isOwner()` | A user may only list or fetch their own categories |
| `create` | `isAuthenticated() && isWritingAsOwner()` | The new document must carry the creator's own UID |
| `update` | `isAuthenticated() && isOwner()` | Only the owner may rename or modify a category |
| `delete` | `isAuthenticated() && isOwner()` | Only the owner may delete a category |

> Note: The app deletes a category's notes via a client-side batch write (see `FirebaseCategoryRepository.deleteCategory`). The `notes` rules below must therefore also permit deletion by the note owner, which they do.

### `/notes/{noteId}`

| Operation | Rule | Reason |
|-----------|------|--------|
| `read` | `isAuthenticated() && isOwner()` | A user may only read their own notes |
| `create` | `isAuthenticated() && isWritingAsOwner()` | The new note must carry the creator's own UID |
| `update` | `isAuthenticated() && isOwner()` | Only the owner may edit note content |
| `delete` | `isAuthenticated() && isOwner()` | Only the owner may delete a note |

## Applying the rules

1. Open the [Firebase Console](https://console.firebase.google.com) and select your project.
2. Navigate to **Firestore Database → Rules**.
3. Replace the existing rules with the block above.
4. Click **Publish**.

Changes take effect within ~1 minute globally.

## Testing

Use the Firebase **Rules Playground** (Console → Firestore → Rules → Rules Playground) to simulate read/write requests with different auth UIDs before publishing.
