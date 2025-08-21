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
    var _awake as Boolean = false;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
        
        centerX = dc.getWidth() / 2;
        centerY = dc.getHeight() / 2;
        radius = (dc.getWidth() < dc.getHeight()) ? dc.getWidth() / 2 : dc.getHeight() / 2;
        // Use full screen - no margin to eliminate black border
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        _awake = true;  // Changed from false - ensure second hand shows immediately when watch face appears
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Clear the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Get current time and date info (timezone-adjusted)
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
        
        // Draw day/date using the timezone-adjusted info
        drawDayDate(dc, today);
        
        // Draw hands (without seconds during low-power mode)
        drawHandsNoSeconds(dc, now);
        
        // Always draw seconds during onUpdate - user is actively viewing the watch
        // onPartialUpdate handles seconds during sleep/low-power mode
        drawSecondHand(dc, now.sec);
    }

    // Partial update for smooth second hand in low-power mode
    function onPartialUpdate(dc as Dc) as Void {
        if (_awake) { 
            return; // Full updates handle everything during wake window
        }
        
        // Get current second for the update
        var sec = System.getClockTime().sec;
        var now = System.getClockTime();
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        
        // Use a larger clipping region that includes battery and date areas
        var handRadius = radius * 0.85; // Expanded to include battery and date
        var clipSize = handRadius * 2;
        dc.setClip(centerX - handRadius, centerY - handRadius, clipSize, clipSize);
        
        // Clear only the clipped area by filling with black background
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(centerX - handRadius, centerY - handRadius, clipSize, clipSize);
        
        // Redraw all elements that might be in the clipped area
        drawBackground(dc);
        drawHourMarkers(dc);
        drawMinuteMarkers(dc);
        drawBattery(dc);  // Include battery indicator
        drawDayDate(dc, today);  // Include date/day indicator
        
        // Redraw the main hands (without seconds) to ensure they stay visible
        drawHandsNoSeconds(dc, now);
        
        // Draw the new second hand position
        drawSecondHand(dc, sec);
        
        // Clear the clipping region to restore normal drawing
        dc.clearClip();
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        // No timer cleanup needed with onPartialUpdate approach
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        _awake = true;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        _awake = false;
    }

    function drawBackground(dc as Dc) as Void {
        // Draw black background circle to full screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, radius);
        
        // Draw outer ring - adjust for pen width to prevent clipping
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawCircle(centerX, centerY, radius - 3);  // Account for pen width
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
                var font = Graphics.FONT_MEDIUM; // Default font for most numbers
                if (numbers[i] == 12 || numbers[i] == 6 || numbers[i] == 9) {
                    font = Graphics.FONT_LARGE; // Make 12, 6, 9 larger than the rest
                }
                
                var text = numbers[i].toString();
                // Better text positioning - use TEXT_JUSTIFY_CENTER for proper alignment
                dc.drawText(x.toNumber(), y.toNumber(), font, text, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
            
            // 24-hour numbers (13-24) - moved closer to main digits
            var hour24Radius = radius * 0.55;  // Fine-tuned positioning (was 0.60)
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
        
        // Get current time info fresh using FORMAT_SHORT to ensure numeric values
        var freshInfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        
        // Get day and date strings
        var dayNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        var dayText = "SAT";  // Updated fallback to current day (Aug 17, 2025)
        var dateText = "17";  // Updated fallback to current date
        
        // Use fresh time info to ensure current data
        if (freshInfo != null) {
            // Get day of month
            if (freshInfo.day != null) {
                dateText = freshInfo.day.toString();
            }
            
            // Get day of week using FORMAT_SHORT which guarantees numeric values
            // day_of_week will be 1-7 where Sunday=1, Monday=2, etc.
            if (freshInfo.day_of_week != null) {
                var dow = freshInfo.day_of_week;
                if (dow instanceof Number && dow >= 1 && dow <= 7) {
                    var index = dow.toNumber() - 1;  // Convert to 0-6 for array index
                    dayText = dayNames[index];
                }
                // Fallback: try manual calculation if numeric check fails
                else if (freshInfo.year != null && freshInfo.month != null && freshInfo.day != null) {
                    dayText = calculateDayOfWeek(freshInfo.year, freshInfo.month, freshInfo.day, dayNames);
                }
            }
            // Final fallback: manual calculation
            else if (freshInfo.year != null && freshInfo.month != null && freshInfo.day != null) {
                dayText = calculateDayOfWeek(freshInfo.year, freshInfo.month, freshInfo.day, dayNames);
            }
        }
        
        // Combine day and date
        var fullText = dayText + " " + dateText;
        
        // Draw date text without background box - white text, slightly bigger font
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK); // White text on black background
        dc.drawText(dateX.toNumber(), dateY.toNumber(), Graphics.FONT_TINY, fullText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    
    // Helper function to calculate day of week using Zeller's congruence (timezone-safe)
    function calculateDayOfWeek(year as Number, month as Number, day as Number, dayNames as Array) as String {
        try {
            // Zeller's congruence algorithm - works with actual date components regardless of timezone
            var adjustedMonth = month;
            var adjustedYear = year;
            
            // For January and February, treat them as months 13 and 14 of the previous year
            if (month <= 2) {
                adjustedMonth = month + 12;
                adjustedYear = year - 1;
            }
            
            var century = (adjustedYear / 100).toNumber();
            var yearOfCentury = adjustedYear % 100;
            
            // Zeller's formula (corrected)
            var dayOfWeek = (day + 
                            ((13 * (adjustedMonth + 1)) / 5).toNumber() + 
                            yearOfCentury + 
                            (yearOfCentury / 4).toNumber() + 
                            (century / 4).toNumber() - 
                            2 * century) % 7;
            
            // Handle negative modulo result
            if (dayOfWeek < 0) {
                dayOfWeek = dayOfWeek + 7;
            }
            
            // Zeller's gives 0=Saturday, 1=Sunday, 2=Monday, etc.
            // Convert to our array index (0=Sunday, 1=Monday, etc.)
            var adjustedDay = (dayOfWeek + 6) % 7;
            
            if (adjustedDay >= 0 && adjustedDay < dayNames.size()) {
                return dayNames[adjustedDay];
            }
        } catch (ex) {
            // Calculation failed
        }
        
        return "SAT"; // Updated fallback to current day (Aug 17, 2025)
    }

    function drawHandsNoSeconds(dc as Dc, clockTime as System.ClockTime) as Void {
        var hourAngle = ((clockTime.hour % 12) * 30 + clockTime.min * 0.5 - 90) * Math.PI / 180.0;
        var minAngle = (clockTime.min * 6 - 90) * Math.PI / 180.0;
        
        // Hour hand - white outline with transparent center and pointed tip
        var hourLength = radius * 0.5;
        var hourX = centerX + hourLength * Math.cos(hourAngle);
        var hourY = centerY + hourLength * Math.sin(hourAngle);
        
        // Create hour hand outline points for a wider hand shape
        var hourWidth = 7; // Half width of the hour hand (increased from 5 for v1.7)
        var perpAngle = hourAngle + Math.PI / 2;
        var hourX1 = centerX + hourWidth * Math.cos(perpAngle);
        var hourY1 = centerY + hourWidth * Math.sin(perpAngle);
        var hourX2 = centerX - hourWidth * Math.cos(perpAngle);
        var hourY2 = centerY - hourWidth * Math.sin(perpAngle);
        var hourX3 = hourX - hourWidth * Math.cos(perpAngle);
        var hourY3 = hourY - hourWidth * Math.sin(perpAngle);
        var hourX4 = hourX + hourWidth * Math.cos(perpAngle);
        var hourY4 = hourY + hourWidth * Math.sin(perpAngle);
        
        // Draw hour hand as solid filled shape (v1.8 - removed transparency)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // Enable anti-aliasing for smoother lines if supported (Fenix 6+ and newer devices)
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        
        // Create filled polygon for solid hour hand with square tip (v1.8 - removed pointed tip)
        var hourPolygon = [
            [hourX1.toNumber(), hourY1.toNumber()], // Base left
            [hourX2.toNumber(), hourY2.toNumber()], // Base right
            [hourX3.toNumber(), hourY3.toNumber()], // Tip right (square end)
            [hourX4.toNumber(), hourY4.toNumber()]  // Tip left (square end)
        ];
        dc.fillPolygon(hourPolygon);

        // Minute hand - white outline with transparent center and pointed tip
        var minLength = radius * 0.7;
        var minX = centerX + minLength * Math.cos(minAngle);
        var minY = centerY + minLength * Math.sin(minAngle);
        
        // Create minute hand outline points for a wider hand shape
        var minWidth = 5; // Half width of the minute hand (increased from 3 for v1.7)
        var minPerpAngle = minAngle + Math.PI / 2;
        var minX1 = centerX + minWidth * Math.cos(minPerpAngle);
        var minY1 = centerY + minWidth * Math.sin(minPerpAngle);
        var minX2 = centerX - minWidth * Math.cos(minPerpAngle);
        var minY2 = centerY - minWidth * Math.sin(minPerpAngle);
        var minX3 = minX - minWidth * Math.cos(minPerpAngle);
        var minY3 = minY - minWidth * Math.sin(minPerpAngle);
        var minX4 = minX + minWidth * Math.cos(minPerpAngle);
        var minY4 = minY + minWidth * Math.sin(minPerpAngle);
        
        // Draw minute hand as solid filled shape (v1.8 - removed transparency)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // Enable anti-aliasing for smoother lines if supported (Fenix 6+ and newer devices)
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        
        // Create filled polygon for solid minute hand with square tip (v1.8 - removed pointed tip)
        var minutePolygon = [
            [minX1.toNumber(), minY1.toNumber()], // Base left
            [minX2.toNumber(), minY2.toNumber()], // Base right
            [minX3.toNumber(), minY3.toNumber()], // Tip right (square end)
            [minX4.toNumber(), minY4.toNumber()]  // Tip left (square end)
        ];
        dc.fillPolygon(minutePolygon);

        // Center circle - larger solid white circle for wider hands
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, 8);  // 8px radius for wider hands (increased from 6)
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawCircle(centerX, centerY, 8);  // Black outline for definition
        
        // Green outer ring around center circle - larger to match wider center
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);  // Thicker green ring
        dc.drawCircle(centerX, centerY, 9);  // 9px radius to create ring around 8px center circle
    }

    function drawSecondHand(dc as Dc, sec as Number) as Void {
        // Second hand - always show for continuous ticking (v1.8 - improved visibility)
        var secAngle = (sec * 6 - 90) * Math.PI / 180.0;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT); // Changed from green to white for v1.8
        dc.setPenWidth(4);  // Widened second hand (increased from 2 for v1.8)
        // Enable anti-aliasing for smoother lines if supported (Fenix 6+ and newer devices)
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        var secLength = radius * 0.8;
        var secX = centerX + secLength * Math.cos(secAngle);
        var secY = centerY + secLength * Math.sin(secAngle);
        // Clean line from center to tip - NO circle at end
        dc.drawLine(centerX, centerY, secX, secY);

        // Center circle - larger solid white circle for wider hands
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, 8);  // 8px radius for wider hands (increased from 6)
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawCircle(centerX, centerY, 8);  // Black outline for definition
        
        // Green outer ring around center circle - larger to match wider center
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);  // Thicker green ring
        dc.drawCircle(centerX, centerY, 9);  // 9px radius to create ring around 8px center circle
    }

    // Efficient clipping region for second hand updates
    function getSecondHandClip(sec as Number) as Array<Number> {
        var fullW = radius * 2;
        var fullH = radius * 2;
        
        // Divide watch face into quadrants based on second position
        if (sec >= 53 || sec <= 7) {          // Right quadrant (12-2 o'clock)
            return [centerX, centerY - radius, radius, fullH];
        } else if (sec >= 8 && sec <= 22) {   // Bottom quadrant (2-5 o'clock)
            return [centerX - radius, centerY, fullW, radius];
        } else if (sec >= 23 && sec <= 37) {  // Left quadrant (5-8 o'clock)
            return [centerX - radius, centerY - radius, radius, fullH];
        } else {                              // Top quadrant (8-11 o'clock)
            return [centerX - radius, centerY - radius, fullW, radius];
        }
    }
}
