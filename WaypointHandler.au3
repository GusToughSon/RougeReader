Global $Waypoints[20][2]  ; Array to store up to 20 waypoints (X and Y)
Global $WaypointCount = 0  ; Keep track of how many waypoints are set
Global $CurrentWaypoint = 0  ; Track the current waypoint being navigated to
Global $Navigating = False  ; Flag to track if navigation is active
Global $Paused = False  ; Flag to track if navigation is paused
Global $BaseAddress, $MemOpen, $WaypointCountLabel, $CurrentWaypointLabel
Global $TargetFound = False  ; Declare $TargetFound here
Global $DebugMode = True    ; Control Debug Mode here

Func SetWaypoint()
    DebugWrite("Setting waypoint..." & @CRLF)

    If $WaypointCount < 20 Then
        $PosX = _MemoryRead($BaseAddress + $PosXOffset, $MemOpen, "dword")
        $PosY = _MemoryRead($BaseAddress + $PosYOffset, $MemOpen, "dword")

        DebugWrite("Waypoint coordinates - X: " & $PosX & ", Y: " & $PosY & @CRLF)

        ; Check if the new waypoint is the same as the previous one
        If $WaypointCount > 0 And $Waypoints[$WaypointCount - 1][0] = $PosX And $Waypoints[$WaypointCount - 1][1] = $PosY Then
            DebugWrite("Duplicate waypoint detected, skipping." & @CRLF)
            Return  ; Ignore if the waypoint is a duplicate
        EndIf

        ; Add new waypoint
        $Waypoints[$WaypointCount][0] = $PosX
        $Waypoints[$WaypointCount][1] = $PosY
        $WaypointCount += 1

        ; Update GUI with waypoint count
        GUICtrlSetData($WaypointCountLabel, "Waypoints: " & $WaypointCount)
        DebugWrite("Waypoint added. Current count: " & $WaypointCount & @CRLF)

    Else
        MsgBox(0, "Error", "Maximum number of waypoints reached.")
        DebugWrite("Error: Maximum waypoints reached." & @CRLF)
    EndIf
EndFunc

Func WipeWaypoints()
    DebugWrite("Wiping all waypoints..." & @CRLF)

    ; Reset all waypoints
    For $i = 0 To 19
        $Waypoints[$i][0] = 0
        $Waypoints[$i][1] = 0
    Next
    $WaypointCount = 0
    $CurrentWaypoint = 0
    $Navigating = False

    ; Update GUI
    GUICtrlSetData($WaypointCountLabel, "Waypoints: 0")
    GUICtrlSetData($CurrentWaypointLabel, "Navigating to Waypoint: N/A")

    MsgBox(0, "Waypoints Cleared", "All waypoints have been wiped.")
    DebugWrite("All waypoints cleared." & @CRLF)
EndFunc

Func StartNavigation()
    DebugWrite("Starting navigation..." & @CRLF)

    If $WaypointCount = 0 Then
        MsgBox(0, "Error", "No waypoints set. Use the '\' hotkey to set waypoints.")
        DebugWrite("Error: No waypoints set." & @CRLF)
        Return
    EndIf

    $Navigating = True
    $CurrentWaypoint = 0

    For $i = 0 To $WaypointCount - 1
        ; Break if navigation is stopped or paused
        If Not $Navigating Then ExitLoop

        ; Navigate to each waypoint
        $CurrentWaypoint = $i + 1
        GUICtrlSetData($CurrentWaypointLabel, "Navigating to Waypoint: " & $CurrentWaypoint)
        DebugWrite("Navigating to waypoint: " & $CurrentWaypoint & @CRLF)

        MoveToWaypoint($Waypoints[$i][0], $Waypoints[$i][1])

        ; Random pause between waypoints
        Sleep(Random(500, 1500))
    Next

    ; Navigate in reverse back to the first waypoint
    For $i = $WaypointCount - 1 To 0 Step -1
        If Not $Navigating Then ExitLoop

        $CurrentWaypoint = $i + 1
        GUICtrlSetData($CurrentWaypointLabel, "Navigating to Waypoint: " & $CurrentWaypoint)
        DebugWrite("Navigating to waypoint: " & $CurrentWaypoint & @CRLF)

        MoveToWaypoint($Waypoints[$i][0], $Waypoints[$i][1])
        Sleep(Random(500, 1500))
    Next

    $Navigating = False
    GUICtrlSetData($CurrentWaypointLabel, "Navigating to Waypoint: N/A")
    DebugWrite("Finished waypoint navigation." & @CRLF)
EndFunc

Func MoveToWaypoint($TargetX, $TargetY)
    DebugWrite("Moving to waypoint - Target X: " & $TargetX & ", Target Y: " & $TargetY & @CRLF)

    While True
        ; Check if navigation is paused or stopped
        If Not $Navigating Then
            DebugWrite("Navigation stopped." & @CRLF)
            ExitLoop
        EndIf

        ; Read current position from memory
        $PosX = _MemoryRead($BaseAddress + $PosXOffset, $MemOpen, "dword")
        $PosY = _MemoryRead($BaseAddress + $PosYOffset, $MemOpen, "dword")

        ; Log current position
        DebugWrite("Current Position - X: " & $PosX & ", Y: " & $PosY & @CRLF)

        ; Calculate the differences (deltas) between current and target positions
        $DeltaX = $TargetX - $PosX
        $DeltaY = $TargetY - $PosY

        ; Log the calculated deltas
        DebugWrite("Calculated Delta - X: " & $DeltaX & ", Y: " & $DeltaY & @CRLF)

        ; Stricter condition to check if we've reached the target (within �1 range)
        If Abs($DeltaX) <= 1 And Abs($DeltaY) <= 1 Then
            DebugWrite("Reached waypoint. Stopping movement." & @CRLF)
            ExitLoop
        EndIf

        ; Prioritize movement based on the larger delta (either X or Y)
        If Abs($DeltaX) > Abs($DeltaY) Then
            ; Handle X movement first (A and D control X-axis)
            If $DeltaX < -1 Then
                DebugWrite("Moving left (A = -X)" & @CRLF)
                Send("{a down}")
                Sleep(100)
                Send("{a up}")
            ElseIf $DeltaX > 1 Then
                DebugWrite("Moving right (D = +X)" & @CRLF)
                Send("{d down}")
                Sleep(100)
                Send("{d up}")
            EndIf
        Else
            ; Handle Y movement (W and S control Y-axis)
            If $DeltaY < -1 Then
                DebugWrite("Moving up (W = -Y)" & @CRLF)
                Send("{w down}")
                Sleep(100)
                Send("{w up}")
            ElseIf $DeltaY > 1 Then
                DebugWrite("Moving down (S = +Y)" & @CRLF)
                Send("{s down}")
                Sleep(100)
                Send("{s up}")
            EndIf
        EndIf

        ; Sleep briefly before checking again
        Sleep(100)  ; Reduced delay for faster response
    WEnd

    DebugWrite("Finished moving to waypoint." & @CRLF)
EndFunc

Func TogglePauseNavigation()
    If $Navigating Then
        $Paused = Not $Paused
        If $Paused Then
            DebugWrite("Navigation Paused." & @CRLF)
        Else
            DebugWrite("Navigation Resumed." & @CRLF)
        EndIf
    EndIf
EndFunc

Func DebugWrite($text)
    If $DebugMode Then
        ConsoleWrite($text)
    EndIf
EndFunc
