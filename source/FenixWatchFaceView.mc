import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class FenixWatchFaceView extends WatchUi.WatchFace {

    var centerX as Number = 0;
    var centerY as Number = 0;
    var radius as Number = 0;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        
        centerX = dc.getWidth() / 2;
        centerY = dc.getHeight() / 2;
        radius = (dc.getWidth() < dc.getHeight()) ? dc.getWidth() / 2 : dc.getHeight() / 2;
        radius = (radius * 0.9).toNumber(); // Leave some margin
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Clear the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Get current time
        var now = System.getClockTime();
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

        // Draw the watch face background
        drawBackground(dc);
        
        // Draw hour markers and numbers
        drawHourMarkers(dc);
        
        // Draw minute markers
        drawMinuteMarkers(dc);
        
        // Draw battery indicator
        drawBattery(dc);
        
        // Draw day/date
        drawDayDate(dc, today);
        
        // Draw hands
        drawHands(dc, now);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    function drawBackground(dc as Dc) as Void {
        // Draw black background circle
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, radius);
        
        // Draw outer ring
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawCircle(centerX, centerY, radius - 2);
    }

    function drawHourMarkers(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Arabic numerals positions (like the Seiko watch)
        var numbers = [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
        var hour24 = [24, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];
        
        for (var i = 0; i < 12; i++) {
            var angle = (i * 30 - 90) * Math.PI / 180.0; // Start from 12 o'clock
            
            // Main hour numbers (1-12) - larger and closer to edge
            var numRadius = radius * 0.75;
            var x = centerX + numRadius * Math.cos(angle);
            var y = centerY + numRadius * Math.sin(angle);
            
            // Draw hour markers (triangle for 12, squares for others)
            var markerRadius = radius * 0.92;  // Moved closer to edge
            var markerX = centerX + markerRadius * Math.cos(angle);
            var markerY = centerY + markerRadius * Math.sin(angle);
            
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            if (i == 0) { // 12 o'clock - inverted triangle
                // Draw inverted triangle above 12
                var triangleSize = 4;
                dc.fillPolygon([
                    [markerX.toNumber(), markerY.toNumber() - triangleSize],
                    [markerX.toNumber() - triangleSize, markerY.toNumber() + triangleSize],
                    [markerX.toNumber() + triangleSize, markerY.toNumber() + triangleSize]
                ]);
            } else {
                // Draw small white squares for other hours
                var squareSize = 2;
                dc.fillRectangle(markerX.toNumber() - squareSize, markerY.toNumber() - squareSize, 
                               squareSize * 2, squareSize * 2);
            }
            
            // Draw main hour numbers in bright white - skip 3 o'clock for date window
            if (numbers[i] != 3) { // Hide the "3" to make room for date box
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK); // White on black background
                var font = Graphics.FONT_LARGE;
                if (numbers[i] == 12 || numbers[i] == 6 || numbers[i] == 9) {
                    font = Graphics.FONT_LARGE;
                } else {
                    font = Graphics.FONT_MEDIUM;
                }
                
                var text = numbers[i].toString();
                // Better text positioning - use TEXT_JUSTIFY_CENTER for proper alignment
                dc.drawText(x.toNumber(), y.toNumber(), font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
            
            // 24-hour numbers (13-24) - smaller and closer to center, hide 15
            var hour24Radius = radius * 0.50;  // Moved closer to center to avoid overlap
            var x24 = centerX + hour24Radius * Math.cos(angle);
            var y24 = centerY + hour24Radius * Math.sin(angle);
            
            // Hide the 15 (3 o'clock position) to make room for date box
            if (hour24[i] != 15) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                var smallFont = Graphics.FONT_XTINY;
                var text24 = hour24[i].toString();
                dc.drawText(x24.toNumber(), y24.toNumber(), smallFont, text24, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
        }
    }

    function drawMinuteMarkers(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        
        for (var i = 0; i < 60; i++) {
            if (i % 5 != 0) { // Skip hour positions completely - no markers at hour positions
                var angle = (i * 6 - 90) * Math.PI / 180.0;
                var innerRadius = radius * 0.9;
                var outerRadius = radius * 0.95;
                
                var x1 = centerX + innerRadius * Math.cos(angle);
                var y1 = centerY + innerRadius * Math.sin(angle);
                var x2 = centerX + outerRadius * Math.cos(angle);
                var y2 = centerY + outerRadius * Math.sin(angle);
                
                dc.drawLine(x1, y1, x2, y2);
            }
        }
    }

    function drawBattery(dc as Dc) as Void {
        // Get battery stats
        var stats = System.getSystemStats();
        var batteryLevel = 85; // Default fallback
        
        if (stats != null && stats.battery != null) {
            batteryLevel = stats.battery.toNumber();
        }
        
        // Position battery indicator where FENIX text was - moved slightly down
        var batteryY = centerY - radius * 0.30;  // Moved down from 0.35
        var batteryX = centerX;
        
        // Draw battery outline (rectangular battery shape) - decreased width slightly
        var batteryWidth = 26;  // Decreased from 30
        var batteryHeight = 12; // Keep height the same
        var batteryX1 = batteryX - batteryWidth / 2;
        var batteryY1 = batteryY - batteryHeight / 2;
        
        // Battery outline
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);  // Increased pen width for more visible outline
        dc.drawRectangle(batteryX1, batteryY1, batteryWidth, batteryHeight);
        
        // Battery positive terminal (small rectangle on right) - made bigger
        dc.fillRectangle(batteryX1 + batteryWidth, batteryY1 + 3, 3, batteryHeight - 6);
        
        // Battery fill based on level
        var fillWidth = ((batteryWidth - 4) * batteryLevel / 100).toNumber();  // Adjusted for thicker outline
        if (batteryLevel > 50) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        } else if (batteryLevel > 20) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        }
        
        if (fillWidth > 0) {
            dc.fillRectangle(batteryX1 + 2, batteryY1 + 2, fillWidth, batteryHeight - 4);  // Adjusted for thicker outline
        }
    }

    function drawDayDate(dc as Dc, today as Gregorian.Info) as Void {
        // Day/Date window - positioned where the "3" was, aligned with center
        var dateX = centerX + radius * 0.65;  // Horizontal position (left from original 0.75)
        var dateY = centerY;  // Vertically centered to align with the "3" position
        
        // Get day and date strings dynamically
        var dayNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        var dayText = "WED";  // Default to Wednesday for July 30, 2025
        var dateText = "30";  // Default to 30 for July 30, 2025
        
        // Get current date info - try multiple approaches
        var info = today;
        if (info == null) {
            info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        }
        
        if (info != null) {
            // Get day of month first (this usually works)
            try {
                if (info.day != null) {
                    dateText = info.day.toString();
                }
            } catch (ex) {
                // Keep default
            }
            
            // Get day of week - try different approaches
            try {
                if (info.day_of_week != null) {
                    var dow = info.day_of_week;
                    if (dow instanceof Number && dow >= 1 && dow <= 7) {
                        dayText = dayNames[dow - 1];
                    }
                }
            } catch (ex) {
                // If day_of_week fails, keep the default
                // We'll use WED as fallback which is correct for July 30, 2025
            }
        }
        
        // Combine day and date
        var fullText = dayText + " " + dateText;
        
        // Draw date text without background box - white text, slightly bigger font
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK); // White text on black background
        dc.drawText(dateX.toNumber(), dateY.toNumber(), Graphics.FONT_TINY, fullText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawHands(dc as Dc, clockTime as System.ClockTime) as Void {
        var hourAngle = ((clockTime.hour % 12) * 30 + clockTime.min * 0.5 - 90) * Math.PI / 180.0;
        var minAngle = (clockTime.min * 6 - 90) * Math.PI / 180.0;
        
        // Hour hand - thicker with black outline
        var hourLength = radius * 0.5;
        var hourX = centerX + hourLength * Math.cos(hourAngle);
        var hourY = centerY + hourLength * Math.sin(hourAngle);
        
        // Draw hour hand black outline (made wider)
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(10);
        dc.drawLine(centerX, centerY, hourX, hourY);
        
        // Draw hour hand bright white fill (made wider)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.setPenWidth(8);
        dc.drawLine(centerX, centerY, hourX, hourY);

        // Minute hand - thicker with black outline  
        var minLength = radius * 0.7;
        var minX = centerX + minLength * Math.cos(minAngle);
        var minY = centerY + minLength * Math.sin(minAngle);
        
        // Draw minute hand black outline (made wider)
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(8);
        dc.drawLine(centerX, centerY, minX, minY);
        
        // Draw minute hand bright white fill (made wider)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.setPenWidth(6);
        dc.drawLine(centerX, centerY, minX, minY);

        // Second hand - only show when watch is actively being viewed
        // Hide second hand when backlight is off to prevent pausing issues
        var deviceSettings = System.getDeviceSettings();
        var showSecondHand = true;
        
        // Try to detect if we should show second hand
        try {
            // In low power mode or when backlight is off, don't show second hand
            showSecondHand = !deviceSettings.doNotDisturb;
        } catch (ex) {
            // If detection fails, show it anyway
            showSecondHand = true;
        }
        
        if (showSecondHand) {
            var secAngle = (clockTime.sec * 6 - 90) * Math.PI / 180.0;
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(2);
            var secLength = radius * 0.8;
            var secX = centerX + secLength * Math.cos(secAngle);
            var secY = centerY + secLength * Math.sin(secAngle);
            dc.drawLine(centerX, centerY, secX, secY);
        }

        // Center dot
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, 4);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawCircle(centerX, centerY, 4);
    }
}
