#!/usr/bin/env python3
"""
Lexi - Upload Curriculum Data to Firestore
==========================================
This script uploads the A1 curriculum and question bank to Firestore.
No server needed - uses Firebase Free Tier (Spark Plan).

Requirements:
    pip install firebase-admin

Usage:
    python scripts/upload_to_firestore.py
"""

import json
import sys
import os

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def upload_to_firestore():
    """Upload curriculum and questions to Firestore."""
    
    try:
        import firebase_admin
        from firebase_admin import credentials, firestore
    except ImportError:
        print("[ERROR] firebase-admin not installed!")
        print("Install it with: pip install firebase-admin")
        return False

    # Initialize Firebase
    try:
        # Try to use default credentials (if firebase login was done)
        cred = credentials.ApplicationDefault()
        firebase_admin.initialize_app(cred, {
            'projectId': 'lexi-language-app',
        })
    except Exception as e:
        print(f"[ERROR] Failed to initialize Firebase: {e}")
        print("\nTo fix this:")
        print("1. Run: firebase login")
        print("2. Run: firebase projects:create lexi-language-app")
        print("3. Run: firebase init firestore")
        return False

    db = firestore.client()

    # Upload curriculum
    print("[1/3] Uploading curriculum...")
    try:
        with open('assets/data/curriculum_a1.json', 'r', encoding='utf-8') as f:
            curriculum_data = json.load(f)
        
        # Upload units
        for unit in curriculum_data.get('units', []):
            unit_ref = db.collection('curriculum').document('a1').collection('units').document(unit['id'])
            unit_ref.set(unit)
            print(f"  ✓ Unit: {unit['title']}")
            
            # Upload lessons
            for lesson in unit.get('lessons', []):
                lesson_ref = unit_ref.collection('lessons').document(lesson['id'])
                lesson_ref.set(lesson)
        
        print(f"  ✓ Uploaded {len(curriculum_data.get('units', []))} units")
    except Exception as e:
        print(f"  ✗ Error uploading curriculum: {e}")
        return False

    # Upload questions
    print("[2/3] Uploading question bank...")
    try:
        with open('assets/data/questions_a1.json', 'r', encoding='utf-8') as f:
            questions_data = json.load(f)
        
        batch = db.batch()
        questions = questions_data.get('questions', [])
        
        for i, question in enumerate(questions):
            q_ref = db.collection('questions').document('a1').collection('questions').document(question['id'])
            batch.set(q_ref, question)
            
            # Commit every 500 questions (Firestore batch limit)
            if (i + 1) % 500 == 0:
                batch.commit()
                batch = db.batch()
                print(f"  ✓ Uploaded {i + 1}/{len(questions)} questions")
        
        # Commit remaining
        batch.commit()
        print(f"  ✓ Uploaded {len(questions)} questions total")
    except Exception as e:
        print(f"  ✗ Error uploading questions: {e}")
        return False

    # Upload metadata
    print("[3/3] Uploading metadata...")
    try:
        metadata = {
            'version': '2.0',
            'level': 'A1',
            'language': 'german',
            'totalUnits': len(curriculum_data.get('units', [])),
            'totalLessons': sum(len(u.get('lessons', [])) for u in curriculum_data.get('units', [])),
            'totalQuestions': len(questions_data.get('questions', [])),
            'lastUpdated': firestore.SERVER_TIMESTAMP
        }
        db.collection('metadata').document('curriculum_a1').set(metadata)
        print("  ✓ Metadata uploaded")
    except Exception as e:
        print(f"  ✗ Error uploading metadata: {e}")

    print("\n" + "=" * 50)
    print("Done! Data uploaded to Firestore successfully.")
    print("=" * 50)
    return True


def verify_upload():
    """Verify that data was uploaded correctly."""
    try:
        import firebase_admin
        from firebase_admin import credentials, firestore
        
        cred = credentials.ApplicationDefault()
        firebase_admin.initialize_app(cred, {
            'projectId': 'lexi-language-app',
        })
        db = firestore.client()
        
        # Check units
        units = db.collection('curriculum').document('a1').collection('units').get()
        print(f"\nVerification: {len(units)} units found")
        
        # Check questions
        questions = db.collection('questions').document('a1').collection('questions').get()
        print(f"Verification: {len(questions)} questions found")
        
        return True
    except Exception as e:
        print(f"Verification failed: {e}")
        return False


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == '--verify':
        verify_upload()
    else:
        success = upload_to_firestore()
        sys.exit(0 if success else 1)
