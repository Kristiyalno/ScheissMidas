#Requires AutoHotkey v2.0
#SingleInstance Force

; ------- CONFIG -------
swapCount := 3           ; Amount of keys (pairs) to ruin -- 3 would affect a total of 6 keys
includeNumbers := true   ; Set to true to include 0-9 in the pool
includeModifiers := true ; Set to true to include Ctrl, Alt, Shift
enableLog := true        ; Keep a record of your suffering
enableNotify := true     ; Get a popup so you know why nothing works
; ----------------------

; Building the list of potential victims
keyPool := ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]

if (includeNumbers)
    keyPool.Push("0","1","2","3","4","5","6","7","8","9")

if (includeModifiers)
    keyPool.Push("LControl", "RControl", "LShift", "RShift", "LAlt", "RAlt")

; Deterministic date-based seeding (YYYYMMDD)
dateString := FormatTime(, "yyyyMMdd")
seed := Number(dateString)
PseudoRandom(s) => Mod((s * 1103515245 + 12345), 2147483648)

; Seeded Fisher-Yates shuffle to ensure the chaos is consistent for the entire day
currentSeed := seed
i := keyPool.Length
while (i > 1) {
    currentSeed := PseudoRandom(currentSeed)
    j := Mod(currentSeed, i) + 1
    temp := keyPool[i]
    keyPool[i] := keyPool[j]
    keyPool[j] := temp
    i--
}

activeSwaps := ""
loopLimit := Min(swapCount, Floor(keyPool.Length / 2))

Loop loopLimit {
    idx1 := (A_Index * 2) - 1
    idx2 := A_Index * 2
    
    k1 := keyPool[idx1]
    k2 := keyPool[idx2]
    
    ; Using $* prefix: 
    ; $ prevents the script from triggering its own hotkeys
    ; * allows the hotkey to fire even if other modifiers are held down
    Hotkey("$*" . k1, SendFunc.Bind(k2))
    Hotkey("$*" . k2, SendFunc.Bind(k1))
    
    activeSwaps .= k1 . " <-> " . k2 . "`n"
}

; Function to handle the key redirection
SendFunc(target, *) {
    Send("{Blind}{" . target . "}")
}

; Logs the swapped keys and stuff
if (enableLog) {
    logEntry := FormatTime(, "yyyy-MM-dd HH:mm:ss") . ": Swapped " . loopLimit . " pairs:`n" . activeSwaps . "--------------------`n"
    try {
        FileAppend(logEntry, "key_swap_log.txt")
    }
}

; MsgBox to notify which keys have been swapped
if (enableNotify) {
    MsgBox("Keyboard sabotage initialized.`n`nSwaps for today:`n" . activeSwaps, "System Notice", "Iconi T10")
}
