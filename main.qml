import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: window
    width: 360
    height: 520
    minimumWidth: 300
    minimumHeight: 460
    visible: true
    title: "nCalc"

    property string expression: ""
    property bool isResult: false
    property double memory: 0.0
    property bool isDesktop: window.width > 500

    // --- Physical Keyboard Input Handling ---
    Item {
        focus: true
        Keys.onPressed: (event) => {
            if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
                handleInput(String.fromCharCode(event.key))
            } else if (event.key === Qt.Key_Plus) {
                handleInput("+")
            } else if (event.key === Qt.Key_Minus) {
                handleInput("-")
            } else if (event.key === Qt.Key_Asterisk) {
                handleInput("*")
            } else if (event.key === Qt.Key_Slash) {
                handleInput("/")
            } else if (event.key === Qt.Key_Period || event.key === Qt.Key_Comma) {
                handleInput(".")
            } else if (event.key === Qt.Key_ParenLeft) {
                handleInput("(")
            } else if (event.key === Qt.Key_ParenRight) {
                handleInput(")")
            } else if (event.key === Qt.Key_Percent) {
                handleInput("%")
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Equal) {
                handleInput("=")
            } else if (event.key === Qt.Key_Backspace) {
                handleInput("⌫")
            } else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Delete) {
                handleInput("C")
            } else if (event.key === Qt.Key_M) {
                window.expression = window.memory.toString()
                window.isResult = true
            }
        }
    }

    // --- Logic ---
    function handleInput(key) {
        switch (key) {
        case "C":
            window.expression = ""
            window.isResult = false
            break

        case "⌫":
            if (window.expression === "Error" || window.isResult) {
                window.expression = ""
                window.isResult = false
            } else if (window.expression.length > 0) {
                window.expression = window.expression.slice(0, -1)
            }
            break

        case "=":
            try {
                let sanitized = window.expression.replace(/[\+\-\*\/]+$/, "")
                let result = eval(sanitized)
                let finalStr = (result !== undefined && !isNaN(result)) ? result.toString() : "Error"
                window.expression = finalStr
            } catch (e) {
                window.expression = "Error"
            }
            window.isResult = true
            break

        case "%":
            if (window.expression === "" || window.expression === "Error") break
            let match = window.expression.match(/^(.*?)([\+\-\*\/])?(\d+\.?\d*)$/)
            if (match) {
                let baseExpr = match[1]
                let op = match[2]
                let pctVal = match[3]

                if (op && baseExpr !== "") {
                    try {
                        let baseNum = Number(eval(baseExpr))
                        let currentNum = Number(pctVal)
                        if (op === "+" || op === "-") {
                            let calculatedPct = baseNum * (currentNum / 100)
                            window.expression = baseExpr + op + calculatedPct.toString()
                        } else if (op === "*" || op === "/") {
                            window.expression = baseExpr + op + (currentNum / 100).toString()
                        }
                    } catch (e) {
                        window.expression = "Error"
                    }
                } else {
                    window.expression = String(Number(pctVal) / 100)
                }
            }
            window.isResult = false
            break

        case ".":
            let parts = window.expression.split(/[\+\-\*\/\(\)]/)
            let currentNum = parts[parts.length - 1]
            if (!currentNum.includes(".")) {
                if (window.expression === "" || window.isResult) {
                    window.expression = "0."
                    window.isResult = false
                } else {
                    window.expression += "."
                }
            }
            break

        default:
            if (window.expression === "Error" || window.isResult) {
                if (!["+", "-", "*", "/"].includes(key)) {
                    window.expression = ""
                }
                window.isResult = false
            }

            let ops = ["+", "-", "*", "/"]
            let lastChar = window.expression.slice(-1)
            if (ops.includes(key) && ops.includes(lastChar)) {
                window.expression = window.expression.slice(0, -1) + key
            } else {
                window.expression += key
            }
            break
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        TextField {
            id: display
            Layout.fillWidth: true
            readOnly: true
            horizontalAlignment: Text.AlignRight
            font.pixelSize: window.isDesktop ? 32 : 28
            font.bold: true
            text: window.expression === "" ? "0" : window.expression
            focus: false
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: ["MC", "MR", "M+", "M-"]

                Button {
                    text: modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: window.isDesktop ? 36 : 46
                    activeFocusOnTab: true

                    onClicked: {
                        let currentVal = 0.0
                        try {
                            currentVal = Number(eval(window.expression))
                            if (isNaN(currentVal)) currentVal = 0.0
                        } catch (e) {
                            currentVal = 0.0
                        }

                        switch (text) {
                        case "MC": window.memory = 0.0; break
                        case "MR": window.expression = window.memory.toString(); window.isResult = true; break
                        case "M+": window.memory += currentVal; window.isResult = true; break
                        case "M-": window.memory -= currentVal; window.isResult = true; break
                        }
                    }
                }
            }
        }

        // Gird 4x6
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 4
            rowSpacing: 6
            columnSpacing: 6

            Repeater {
                model: [
                    "C",  "(", ")", "⌫",
                    "7", "8", "9", "/",
                    "4", "5", "6", "*",
                    "1", "2", "3", "-",
                    "%", "0", ".", "+",
                    "±", "√", "x²", "="
                ]

                Button {
                    text: modelData
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    font.pixelSize: window.isDesktop ? 18 : 22
                    font.bold: modelData === "="
                    highlighted: modelData === "="

                    palette.button: modelData === "=" ? "#FF9500" : undefined
                    palette.buttonText: modelData === "=" ? "#FFFFFF" : undefined
                    palette.windowText: modelData === "=" ? "#FFFFFF" : undefined
                    palette.highlight: modelData === "=" ? "#FF9500" : undefined
                    palette.highlightedText: modelData === "=" ? "#FFFFFF" : undefined

                    activeFocusOnTab: true

                    onClicked: {
                        if (modelData === "±") {
                            if (window.expression.startsWith("-")) {
                                window.expression = window.expression.substring(1)
                            } else if (window.expression !== "" && window.expression !== "0") {
                                window.expression = "-" + window.expression
                            }
                        } else if (modelData === "√") {
                            try {
                                let val = Number(eval(window.expression))
                                window.expression = Math.sqrt(val).toString()
                                window.isResult = true
                            } catch (e) {
                                window.expression = "Error"
                            }
                        } else if (modelData === "x²") {
                            try {
                                let val = Number(eval(window.expression))
                                window.expression = Math.pow(val, 2).toString()
                                window.isResult = true
                            } catch (e) {
                                window.expression = "Error"
                            }
                        } else {
                            handleInput(modelData)
                        }
                    }
                }
            }
        }
    }
}
