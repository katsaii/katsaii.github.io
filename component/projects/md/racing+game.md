The result of a group project assignment where we were tasked to create a video game with networking and database connectivity. I was responsible for the implementation of the netcode, artificial intelligence of non-player drivers, and physics. Additionally I worked partially on the graphics and system integration.

<div class="centre">
	<%= figure("/video/racing-game-1.webm", desc: "Gameplay demo", width: 500, ref: 1, type: :video) %>
</div>

<br>

The netcode architecture is client-server, where one user acts as a host to other players. Verification of the physics world is performed on the server-side before being transmitted to all clients. This allows players to collide with each other in real time using simple circle-circle physics intersections. Additionally, the server uses a process similar to boids in order to make decisions about how non-player drivers should follow the road. These decisions are then used to simulate inputs for the AI driver so that it has no technical advantage over other players.

<div class="centre">
	<%= figure("/video/racing-game-2.webm", desc: "Racing against an AI player", width: 500, ref: 2, type: :video) %>
</div>
