using Godot;

/// <summary>
/// Smooth fixed-axis follow camera.
/// Keeps a constant world-space offset from the player and smoothly interpolates
/// toward the target position each frame, then looks at the player.
/// Attach this script to the Camera3D node.
/// </summary>
public partial class FollowCamera : Camera3D
{
	/// <summary>World-space offset from the player's origin.</summary>
	[Export] public Vector3 Offset = new Vector3(0f, 9f, 5f);

	/// <summary>How quickly the camera catches up to the target position (higher = snappier).</summary>
	[Export] public float SmoothSpeed = 7f;

	/// <summary>
	/// The target the camera looks at — slightly above the player's origin
	/// so the character is framed in the lower portion of the view.
	/// </summary>
	[Export] public float LookAtHeightOffset = 0.8f;

	// The player node; resolved automatically from the parent in _Ready.
	private Node3D _player;

	public override void _Ready()
	{
		// Camera lives as a child of the Player node but moves in world space.
		_player = GetParent<Node3D>();
		if (_player == null)
		{
			GD.PushError($"{Name}: FollowCamera must be a child of a Node3D (the player).");
			return;
		}

		// Snap to the correct position immediately so there is no startup lerp.
		GlobalPosition = _player.GlobalPosition + Offset;
	}

	public override void _Process(double delta)
	{
		if (_player == null)
			return;

		Vector3 targetPosition = _player.GlobalPosition + Offset;

		// Smooth exponential follow — frame-rate independent.
		GlobalPosition = GlobalPosition.Lerp(targetPosition, SmoothSpeed * (float)delta);

		// Always look slightly above the player's feet so the character is centred.
		LookAt(_player.GlobalPosition + Vector3.Up * LookAtHeightOffset);
	}
}
