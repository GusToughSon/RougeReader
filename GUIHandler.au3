#include <GUIConstantsEx.au3>

Global $Gui, $TypeLabel, $AttackModeLabel, $PosXLabel, $PosYLabel, $HPLabel, $HP2Label, $MaxHPLabel, $HealerLabel, $ThresholdSlider, $KillButton, $ExitButton
Global $WaypointCountLabel, $CurrentWaypointLabel

Func CreateGUI()
    ; Create the GUI with the title "RogueReader"
    $Gui = GUICreate("RogueReader", 450, 550, 15, 15)

    ; Create labels for displaying memory information
    $TypeLabel = GUICtrlCreateLabel("Type: N/A", 20, 30, 250, 20)
    $AttackModeLabel = GUICtrlCreateLabel("Attack Mode: N/A", 20, 60, 250, 20)
    $PosXLabel = GUICtrlCreateLabel("Pos X: N/A", 20, 90, 250, 20)
    $PosYLabel = GUICtrlCreateLabel("Pos Y: N/A", 20, 120, 250, 20)
    $HPLabel = GUICtrlCreateLabel("HP: N/A", 20, 150, 250, 20)
    $HP2Label = GUICtrlCreateLabel("HP2: N/A", 20, 180, 250, 20)
    $MaxHPLabel = GUICtrlCreateLabel("MaxHP: N/A", 20, 210, 250, 20)
    $HealerLabel = GUICtrlCreateLabel("Healer: OFF", 20, 240, 250, 20)

    ; Create labels to show waypoints
    $WaypointCountLabel = GUICtrlCreateLabel("Waypoints: 0", 20, 270, 250, 20)
    $CurrentWaypointLabel = GUICtrlCreateLabel("Navigating to Waypoint: N/A", 20, 300, 250, 20)

    ; Hotkey labels to display the hotkeys used in the tool
    GUICtrlCreateLabel("Hotkeys:", 20, 340, 250, 20)
    GUICtrlCreateLabel("\ : Set a new waypoint", 20, 360, 250, 20)
    GUICtrlCreateLabel("] : Wipe all waypoints", 20, 380, 250, 20)
    GUICtrlCreateLabel("/ : Start navigation", 20, 400, 250, 20)
    GUICtrlCreateLabel("' : Pause/Resume navigation", 20, 420, 250, 20)

    ; Create slider for healing threshold
    GUICtrlCreateLabel("Heal Threshold: 95%", 20, 450, 250, 20)
    $ThresholdSlider = GUICtrlCreateSlider(20, 470, 200, 30)
    GUICtrlSetLimit($ThresholdSlider, 100, 0)
    GUICtrlSetData($ThresholdSlider, 95)

    ; Create buttons
    $KillButton = GUICtrlCreateButton("Kill Rogue", 20, 510, 100, 30)
    $ExitButton = GUICtrlCreateButton("Exit", 150, 510, 100, 30)

    ; Show the GUI
    GUISetState(@SW_SHOW)
EndFunc

Func UpdateGUI($Type, $AttackMode, $PosX, $PosY, $HP, $MaxHP)
    ; Update the GUI with new values from memory
    If $Type = 0 Then
        GUICtrlSetData($TypeLabel, "Type: Player (" & $Type & ")")
    ElseIf $Type = 1 Then
        GUICtrlSetData($TypeLabel, "Type: Monster (" & $Type & ")")
    ElseIf $Type = 2 Then
        GUICtrlSetData($TypeLabel, "Type: NPC (" & $Type & ")")
    Else
        GUICtrlSetData($TypeLabel, "Type: No Target (" & $Type & ")")
    EndIf

    If $AttackMode = 0 Then
        GUICtrlSetData($AttackModeLabel, "Attack Mode: Safe")
    ElseIf $AttackMode = 1 Then
        GUICtrlSetData($AttackModeLabel, "Attack Mode: Attack")
    Else
        GUICtrlSetData($AttackModeLabel, "Attack Mode: No Target")
    EndIf

    GUICtrlSetData($PosXLabel, "Pos X: " & $PosX)
    GUICtrlSetData($PosYLabel, "Pos Y: " & $PosY)
    GUICtrlSetData($HPLabel, "HP: " & $HP)
    GUICtrlSetData($MaxHPLabel, "MaxHP: " & $MaxHP)
    $HP2 = $HP / 65536
    GUICtrlSetData($HP2Label, "HP2: " & $HP2)
EndFunc
