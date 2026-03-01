using Godot;

/// <summary>
/// Player controller for Botched Batch Brewery.
///
/// Features:
/// - Camera-relative movement input (WASD / arrow keys)
/// - Smooth acceleration and friction
/// - Player mesh rotates to face the direction of travel
/// - Squash &amp; stretch on jump and land
/// - Running bob while moving on the ground
/// - Coyote time for forgiving edge jumps
/// </summary>
public partial class Player : CharacterBody3D
{
	// ── Movement ──────────────────────────────────────────────────────────────
	public const float Speed = 6.0f;
	public const float Acceleration = 22.0f;
	public const float Friction = 20.0f;
	public const float JumpVelocity = 5.5f;

	/// <summary>Seconds the player can still jump after walking off a ledge.</summary>
	public const float CoyoteTime = 0.12f;

	/// <summary>How fast the mesh visually rotates to face the direction of travel.</summary>
	public const float TurnSpeed = 14.0f;

	// ── Squash & Stretch ──────────────────────────────────────────────────────
	private static readonly Vector3 StretchScale = new Vector3(0.72f, 1.38f, 0.72f);
	private static readonly Vector3 SquashScale = new Vector3(1.38f, 0.68f, 1.38f);

	/// <summary>How fast the mesh scale springs back to (1,1,1) after a squash or stretch.</summary>
	public const float ScaleSpringSpeed = 14.0f;

	// ── Running Bob ───────────────────────────────────────────────────────────
	public const float BobAmplitude = 0.06f;
	public const float BobFrequency = 2.4f;

	// ── Exported references ───────────────────────────────────────────────────
	/// <summary>Camera used to orient movement input. Resolved from children if not set.</summary>
	[Export] public Camera3D Camera;

	// ── Cached node references ────────────────────────────────────────────────
	private MeshInstance3D _mesh;

	// ── Internal state ────────────────────────────────────────────────────────
	private float _coyoteTimer = 0f;
	private bool _wasOnFloor = false;
	private Vector3 _targetScale = Vector3.One;
	private float _bobTime = 0f;
	private float _meshBaseY = 1.0f;

	public override void _Ready()
	{
		_mesh = GetNodeOrNull<MeshInstance3D>("MeshInstance3D");
		if (_mesh == null)
		{
			GD.PushError($"{Name}: MeshInstance3D child not found. Squash/stretch and bob will not work.");
			return;
		}
		_meshBaseY = _mesh.Position.Y;

		if (Camera == null)
			Camera = GetNodeOrNull<Camera3D>("Camera3D");

		if (Camera == null)
			GD.PushWarning($"{Name}: No Camera3D found. Movement will fall back to world-relative input.");
	}

	public override void _PhysicsProcess(double delta)
	{
		float dt = (float)delta;
		Vector3 velocity = Velocity;

		// ── Gravity ───────────────────────────────────────────────────────────
		bool onFloor = IsOnFloor();
		if (!onFloor)
		{
			velocity += GetGravity() * dt;
		}

		// ── Coyote time ───────────────────────────────────────────────────────
		if (onFloor)
		{
			_coyoteTimer = CoyoteTime;
		}
		else
		{
			_coyoteTimer -= dt;
		}

		// ── Jump ──────────────────────────────────────────────────────────────
		if (Input.IsActionJustPressed("ui_accept") && _coyoteTimer > 0f)
		{
			velocity.Y = JumpVelocity;
			_coyoteTimer = 0f;

			if (_mesh != null)
			{
				_mesh.Scale = StretchScale;
				_targetScale = Vector3.One;
			}
		}

		// ── Detect landing ────────────────────────────────────────────────────
		if (!_wasOnFloor && onFloor)
		{
			if (_mesh != null)
			{
				_mesh.Scale = SquashScale;
				_targetScale = Vector3.One;
			}
		}
		_wasOnFloor = onFloor;

		// ── Camera-relative input ─────────────────────────────────────────────
		Vector2 inputDir = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");

		Vector3 moveDir = Vector3.Zero;
		if (inputDir != Vector2.Zero)
		{
			if (Camera != null)
			{
				Vector3 camForward = -Camera.GlobalTransform.Basis.Z;
				camForward.Y = 0f;
				camForward = camForward.Normalized();

				Vector3 camRight = Camera.GlobalTransform.Basis.X;
				camRight.Y = 0f;
				camRight = camRight.Normalized();

				moveDir = (camRight * inputDir.X + camForward * -inputDir.Y).Normalized();
			}
			else
			{
				moveDir = new Vector3(inputDir.X, 0f, inputDir.Y).Normalized();
			}
		}

		// ── Acceleration / Friction ───────────────────────────────────────────
		if (moveDir != Vector3.Zero)
		{
			velocity.X = Mathf.MoveToward(velocity.X, moveDir.X * Speed, Acceleration * dt);
			velocity.Z = Mathf.MoveToward(velocity.Z, moveDir.Z * Speed, Acceleration * dt);
		}
		else
		{
			velocity.X = Mathf.MoveToward(velocity.X, 0f, Friction * dt);
			velocity.Z = Mathf.MoveToward(velocity.Z, 0f, Friction * dt);
		}

		// ── Player mesh facing direction ──────────────────────────────────────
		if (moveDir != Vector3.Zero && _mesh != null)
		{
			float targetAngle = Mathf.Atan2(moveDir.X, moveDir.Z);
			float currentAngle = _mesh.Rotation.Y;
			float newAngle = Mathf.LerpAngle(currentAngle, targetAngle, TurnSpeed * dt);
			_mesh.Rotation = new Vector3(0f, newAngle, 0f);
		}

		// ── Running bob ───────────────────────────────────────────────────────
		if (_mesh != null)
		{
			float horizontalSpeed = new Vector2(velocity.X, velocity.Z).Length();

			if (onFloor && horizontalSpeed > 0.5f)
			{
				_bobTime += dt * BobFrequency * Mathf.Tau;
				float bobY = Mathf.Sin(_bobTime) * BobAmplitude;
				_mesh.Position = new Vector3(_mesh.Position.X, _meshBaseY + bobY, _mesh.Position.Z);
			}
			else
			{
				_bobTime = 0f;
				_mesh.Position = new Vector3(
					_mesh.Position.X,
					Mathf.MoveToward(_mesh.Position.Y, _meshBaseY, 4f * dt),
					_mesh.Position.Z
				);
			}

			// ── Scale spring ──────────────────────────────────────────────────
			_mesh.Scale = _mesh.Scale.Lerp(_targetScale, ScaleSpringSpeed * dt);
		}

		Velocity = velocity;
		MoveAndSlide();
	}
}
