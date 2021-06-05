extends Node
class_name PhysicsHelper

static func calculate_arc_v0(p0 : Vector2, p2 : Vector2, \
                                   arc : int, gravity : float) -> Vector2:
  var v0 : Vector2
  var d : Vector2 = p2 - p0
  v0.y = - sqrt(-2 * gravity * arc)
  var t1 : float = (-v0.y + sqrt(pow(v0.y, 2) + 2 * arc *gravity)) / gravity
  var t2 : float = t1 + sqrt(2 * (d.y - arc) / gravity)

  v0.x = d.x/t2

  return v0
