using Godot;
using System.Collections.Generic;

/// <summary>
/// Handles grid-based placement of objects in the world.
/// Requires a GridMap for snapping and collision reference.
/// </summary>
public partial class GridPlacementSystem : Node3D
{
	[Export] public GridMap TargetGridMap;
	[Export] public PackedScene ObjectToPlace;
	[Export] public Node3D PlacedObjectsContainer;

	private Dictionary<Vector3I, Node3D> _placedObjects = new Dictionary<Vector3I, Node3D>();
	private MeshInstance3D _previewMesh;
	private StandardMaterial3D _previewMaterial;
	
	// Raycast length
	private const float RayLength = 1000f;

	private Vector3I _currentGridPos;
	private bool _isCurrentGridValid;

	public override void _Ready()
	{
		if (TargetGridMap == null)
		{
			GD.PushError($"{Name}: TargetGridMap is not assigned.");
			return;
		}

		if (PlacedObjectsContainer == null)
		{
			GD.PushError($"{Name}: PlacedObjectsContainer is not assigned.");
			return;
		}

		// Create a preview mesh (ghost cursor)
		_previewMesh = new MeshInstance3D();
		
		var boxMesh = new BoxMesh();
		boxMesh.Size = TargetGridMap.CellSize;
		_previewMesh.Mesh = boxMesh;

		_previewMaterial = new StandardMaterial3D();
		_previewMaterial.Transparency = BaseMaterial3D.TransparencyEnum.Alpha;
		_previewMaterial.AlbedoColor = new Color(0, 1, 0, 0.5f);
		_previewMesh.MaterialOverride = _previewMaterial;

		// Disable collision on the preview
		AddChild(_previewMesh);
	}

	public override void _Process(double delta)
	{
		if (TargetGridMap == null) return;

		Camera3D camera = GetViewport().GetCamera3D();
		if (camera == null) return;

		Vector2 mousePos = GetViewport().GetMousePosition();
		Vector3 rayOrigin = camera.ProjectRayOrigin(mousePos);
		Vector3 rayEnd = rayOrigin + camera.ProjectRayNormal(mousePos) * RayLength;

		var spaceState = GetWorld3D().DirectSpaceState;
		var query = PhysicsRayQueryParameters3D.Create(rayOrigin, rayEnd);
		// You might want to filter by collision mask so it only hits the grid/terrain

		var result = spaceState.IntersectRay(query);

		if (result.Count > 0)
		{
			_previewMesh.Visible = true;
			Vector3 hitPos = (Vector3)result["position"];
			
			// Slightly adjust the hit position upward if we hit exactly on the floor, 
			// to ensure we select the cell *above* the floor.
			// The grid map local to map converts world pos to cell index.
			Vector3 localHitPos = TargetGridMap.ToLocal(hitPos);
			
			// Add a small offset based on the hit normal to make sure we select the empty space
			Vector3 hitNormal = (Vector3)result["normal"];
			Vector3 adjustedLocalHitPos = localHitPos + (hitNormal * 0.1f);
			
			_currentGridPos = TargetGridMap.LocalToMap(adjustedLocalHitPos);
			
			// Center the preview mesh on the grid cell
			Vector3 mapLocalPos = TargetGridMap.MapToLocal(_currentGridPos);
			_previewMesh.GlobalPosition = TargetGridMap.ToGlobal(mapLocalPos);

			// Check validity
			_isCurrentGridValid = !_placedObjects.ContainsKey(_currentGridPos);

			if (_isCurrentGridValid)
			{
				_previewMaterial.AlbedoColor = new Color(0, 1, 0, 0.5f); // Green
			}
			else
			{
				_previewMaterial.AlbedoColor = new Color(1, 0, 0, 0.5f); // Red
			}
		}
		else
		{
			_previewMesh.Visible = false;
			_isCurrentGridValid = false;
		}
	}

	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event.IsActionPressed("place_object"))
		{
			if (_previewMesh.Visible && _isCurrentGridValid)
			{
				PlaceObject();
				GetViewport().SetInputAsHandled();
			}
		}
	}

	private void PlaceObject()
	{
		if (ObjectToPlace == null)
		{
			GD.PushError($"{Name}: ObjectToPlace is not assigned.");
			return;
		}

		Node3D newObj = ObjectToPlace.Instantiate<Node3D>();
		PlacedObjectsContainer.AddChild(newObj);
		
		// Set position to the exact center of the grid cell
		Vector3 mapLocalPos = TargetGridMap.MapToLocal(_currentGridPos);
		newObj.GlobalPosition = TargetGridMap.ToGlobal(mapLocalPos);

		// Store in dictionary
		_placedObjects.Add(_currentGridPos, newObj);
	}
}
