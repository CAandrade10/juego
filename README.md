# nombre del juego:
RunMonkey
# descripcion del juego: 
controlaras a un mono aventurero que debe recoger bananas en cada nivel para avanzar. El juego cuenta con dos niveles ambientados en escenarios distintos, y solo al completar el primero puedes desbloquear el segundo. ¡Explora, salta y recoge bananas para ganar.
# caracteristicas:
Juego en 2D

Basado en plataformas fijas y frajil

Protagonizado por un mono recolector de bananas

Puedes recoger bananas y acumular puntos

Permite guardar el progreso del juego

# Listado de assets empleados:
personaje:

"
"[Copilot_20250725_001438.zip](https://github.com/user-attachments/files/21636472/Copilot_20250725_001438.zip)"

objeto:

"[banana.zip](https://github.com/user-attachments/files/21636554/banana.zip)
"

nivel 1:

"[fondo.zip](https://github.com/user-attachments/files/21636356/fondo.zip)"

"[cabezacoco.zip](https://github.com/user-attachments/files/21636537/cabezacoco.zip)
"
"[hingo1.zip](https://github.com/user-attachments/files/21636572/hingo1.zip)
"
"[ocean.zip](https://github.com/user-attachments/files/21636599/ocean.zip)
"
"[plataforma0.1.zip](https://github.com/user-attachments/files/21636624/plataforma0.1.zip)
"
"[serpiente.zip](https://github.com/user-attachments/files/21636655/serpiente.zip)
"
"[suelo1.zip](https://github.com/user-attachments/files/21636663/suelo1.zip)
"

nivel 2:

"[espacio.zip](https://github.com/user-attachments/files/21636272/espacio.zip)
"
"[espacio2.zip](https://github.com/user-attachments/files/21636308/espacio2.zip)"

"[lunar.zip](https://github.com/user-attachments/files/21636588/lunar.zip)
"
"[doorespace.zip](https://github.com/user-attachments/files/21637387/doorespace.zip)
"

# peronaje
```gdscript
extends CharacterBody2D

# --- Variables del jugador ---
var vida : int = 100
var puntaje : int = 0
var velocidad : int = 600
var gravedad : int = 1000
var fuerza_salto : int = -600

@onready var label_puntaje : Label = $"../UI_Puntaje"

func _ready():
	actualizar_label()
	add_to_group("jugador")  # Añade al grupo al cargar la escena

func _physics_process(delta):
	# Movimiento y gravedad (como antes)
	if not is_on_floor():
		velocity.y += gravedad * delta
	
	var direccion = Input.get_axis("ui_left", "ui_right")
	velocity.x = direccion * velocidad
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = fuerza_salto
	
	move_and_slide()
	
	if Input.is_action_pressed("guardar"):
		guardar_datos()
	if Input.is_action_pressed("cargar"):
		cargar_datos()
	


# --- Sistema de puntos y Label ---
func sumar_puntos(cantidad : int):
	puntaje += cantidad
	actualizar_label()

func actualizar_label():
	label_puntaje.text = "Vida: %d\nPuntos: %d" % [vida, puntaje]
	


func guardar_datos():
	
	var datos = {
		"jugador": {
			"puntaje": puntaje,
			"vida": vida,
			"posicion": {
				"x": "%.8f" % global_position.x,
				"y": "%.8f" % global_position.y
			}			
		}
	}
	#Código para guardar JSON
	var json_texto = JSON.stringify(datos, "\t")
	var archivo = FileAccess.open("res://juego_guardado.json",FileAccess.WRITE)
	archivo.store_string(json_texto)
	archivo.close()
	print("Todo salió bien, archivo guardado")
	
	
func cargar_datos():
	
	if not FileAccess.file_exists("res://juego_guardado.json"):
		print("No hay archivo")
		return
		
	var archivo = FileAccess.open("res://juego_guardado.json",FileAccess.READ)
	var json_caracter = archivo.get_as_text()
	archivo.close()
	
	var json = JSON.new()
	var error = json.parse(json_caracter)
	if error != OK:
		print("No se parseó", json.get_error_message())
	
	var datos = json.get_data()
	
	global_position = Vector2(		
		float(datos["jugador"]["posicion"]["x"]),
		float(datos["jugador"]["posicion"]["y"])
	)
	
	vida = datos["jugador"]["vida"]
	puntaje = datos["jugador"]["puntaje"]
	actualizar_label()
```
# plataforma
```gdscript
extends Area2D

enum TipoPlataforma {FIJA, OSCILATORIA, FRAGIL, REBOTE}
@export var tipo: TipoPlataforma = TipoPlataforma.FIJA;
@export var fuerza_rebote := 2.0

func _ready():
	actualizar_plataforma()
	monitorable = true
	monitoring = true
	
func actualizar_plataforma():
	match tipo:
		TipoPlataforma.FIJA:
			$Sprite2D.modulate = Color.GREEN
		TipoPlataforma.OSCILATORIA:
			$Sprite2D.modulate = Color.BLUE
			oscilar()
		TipoPlataforma.FRAGIL:
			$Sprite2D.modulate = Color.RED
		TipoPlataforma.REBOTE:
			$Sprite2D.modulate = Color.YELLOW
		


	
func oscilar():
	var tween = create_tween()
	tween.tween_property(self,"position:x",position.x + 100,2)
	tween.tween_property(self,"position:x",position.x - 100,2)
	tween.set_loops()




func _on_body_entered(body: Node2D) -> void:

	if body.is_in_group("jugador"):
	
		match tipo:
			TipoPlataforma.FRAGIL:
				await get_tree().create_timer(0.5).timeout
				queue_free()
			TipoPlataforma.REBOTE:
				if body.has_method("puede_rebotar"):
					body.pauede_rebotar(fuerza_rebote)
				else:
					body.velocity.y = body.brinco * fuerza_rebote
	pass # Replace with function body.
```
# puerta
```gdscript
func _on_area_2d_16_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://nivel1/nivel.1.tscn")
	pass # Replace with function body.
```
# banana
```gdscript
extends Area2D

# Variable para el valor del puntaje que da esta moneda.
var valor_puntos : int = 100

func _ready():
	# Conectamos la señal de body_entered (cuando el jugador toca la moneda).
	body_entered.connect(_on_body_entered)
	add_to_group("monedas")  # Añade al grupo al cargar la escena

func _on_body_entered(body : Node):
	if body.is_in_group("jugador"):  # Asegurarse de que solo el jugador la recoja.
		body.sumar_puntos(valor_puntos)  # Llama a una función en el jugador.
		queue_free()  # Elimina la moneda de la escena.
```
# zona de eliminacion
```gdscript
func _on_area_2d_11_body_entered(body: Node2D) -> void:
	get_tree().reload_current_scene()
```
# guardar y cargar
```gdscript
{
	"jugador": {
		"posicion": {
			"x": "0",
			"y": "0"
		},
		"puntaje": 0,
		"vida": 100
	}
}
```
# videos

"https://youtu.be/kBN7FD-LmRI?si=DvboBc-9U7u1jySf"

"https://youtu.be/CsxBqWM8Yqg?si=Xc1xjaJiufowQjus"

# Comentarios finales:
mi experiencia en el desarrollo de videojuego fue muy interasante y divertida ya que cualquier idea la puedes implementar en un videojuego como tambien hubo casos complicados que tuve que afrontar.

# comprimido del juego:

"[mokeygame.zip](https://github.com/user-attachments/files/21641567/mokeygame.zip)
"


