# Player-hosted multiplayer design

## Goal
Let one player create a private room and host the match on their own computer. Friends join that player's session. This is a planned architecture, not working multiplayer code yet.

## First version
1. The host chooses **Create Room**.
2. The game starts a host session and shows a join code.
3. Friends choose **Join Room** and enter the code.
4. Connected players send input to the host; the host owns authoritative gameplay state and sends updates back.
5. If the host leaves or disconnects, the session ends with a clear message. Host migration can be considered later.

## Connection reality
A room code is only an identifier; it does not automatically connect computers across the internet. Players on the same LAN are the easiest first networking test. Internet play may need a signalling service, NAT traversal, or a relay. A relay can use bandwidth and may not remain free at scale.

Do not expose a home computer by asking players to disable their firewall. If port forwarding is ever offered, explain the risks and make it optional. Prefer a secure relay or a carefully documented connection method for public play.

## Godot implementation direction
- Start with Godot's high-level multiplayer API and ENet for a small desktop prototype.
- First test host and client on the same computer, then two computers on the same local network.
- Add room codes / internet matchmaking only after basic synchronization works.
- Synchronize player transforms and gravity state; keep important puzzle decisions host-authoritative.
- Validate incoming remote calls and limit what clients are allowed to request.
- Keep the initial player count small and measure bandwidth before increasing it.

## Milestones
- [ ] Create and stop a local host session
- [ ] Join from a second game instance on the same computer
- [ ] Synchronize player movement and gravity flipping
- [ ] Test over a local network
- [ ] Choose a safe internet connection / relay strategy
- [ ] Add private room codes and disconnect handling

## Scope and costs
Player-hosted rooms remove the need for a dedicated game server for every match, but they do not guarantee zero infrastructure cost. Reliable room discovery and connections across home routers may still require a small signalling or relay service.
