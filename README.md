סעיף 1:
המחלקה שמממשת את ה-controller נקראת SnappingSheetController.
פיצ'רים:
•	snapToPosition – קפיצה למיקום מסויים (אנימציה)
•	setSnappingSheetPosition – קביעת מיקום (ללא אנימציה)
•	currentPosition – השגת המיקום הנוכחי של ה-sheet
•	currentlySnapping – בדיקה האם ה-sheet באמצע snapping
•	stopCurrentSnapping – עצירת snapping נוכחי

סעיף 2:
•	מי ששולט על האנימציה זה השדה _animationController שהוא טיפוס מסוג AnimationController

סעיף 3:
•	ל- GestureDetectorיש הרבה יותר שדות (תכונות ופיצ'רים) מאשר ל-InkWell 
•	ל-InkWell יש אפשרות להוסיף אנימציות (למשל ripple) וצבעים ול- GestureDetector אין את האפשרות הזו.
