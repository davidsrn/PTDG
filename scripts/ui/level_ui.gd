extends CanvasLayer

## Level UI Controller
## Manages UI updates and user interactions

@onready var credits_label: Label = $TopBar/CreditsLabel
@onready var wave_label: Label = $TopBar/WaveLabel
@onready var health_label: Label = $TopBar/HealthLabel
@onready var processor_cores_label: Label = $TopBar/ProcessorCoresLabel
@onready var start_wave_button: Button = $BottomBar/StartWaveButton


func _ready() -> void:
	# Connect to GameManager signals
	if GameManager:
		GameManager.credits_changed.connect(_on_credits_changed)
		GameManager.processor_cores_changed.connect(_on_processor_cores_changed)
		GameManager.wave_started.connect(_on_wave_started)
		GameManager.wave_completed.connect(_on_wave_completed)

	# Connect button
	if start_wave_button:
		start_wave_button.pressed.connect(_on_start_wave_pressed)

	# Initial update
	_update_all_labels()


func _process(_delta: float) -> void:
	# Update health label continuously
	if health_label and GameManager:
		health_label.text = "Health: " + str(GameManager.player_health)


## Update all UI labels
func _update_all_labels() -> void:
	if GameManager:
		_on_credits_changed(GameManager.credits)
		_on_processor_cores_changed(GameManager.processor_cores)
		wave_label.text = "Wave: " + str(GameManager.current_wave)
		health_label.text = "Health: " + str(GameManager.player_health)


## Called when credits change
func _on_credits_changed(new_amount: int) -> void:
	if credits_label:
		credits_label.text = "Credits: " + str(new_amount)


## Called when processor cores change
func _on_processor_cores_changed(new_amount: int) -> void:
	if processor_cores_label:
		processor_cores_label.text = "Cores: " + str(new_amount)


## Called when wave starts
func _on_wave_started(wave_number: int) -> void:
	if wave_label:
		wave_label.text = "Wave: " + str(wave_number)

	# Disable start button during wave
	if start_wave_button:
		start_wave_button.disabled = true
		start_wave_button.text = "Wave Active..."


## Called when wave completes
func _on_wave_completed(wave_number: int) -> void:
	# Re-enable start button
	if start_wave_button:
		start_wave_button.disabled = false
		start_wave_button.text = "Start Wave " + str(wave_number + 1)


## Called when start wave button is pressed
func _on_start_wave_pressed() -> void:
	if GameManager and not GameManager.is_wave_active:
		GameManager.start_wave()
