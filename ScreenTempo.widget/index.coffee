# ------------------------------------------------------------
# Screen Tempo — Übersicht
# Visual pulse synced to BPM, optional click sound (OFF by default)
# Author: Carlos Abeijón Martínez
# ------------------------------------------------------------

refreshFrequency: false               # we drive the loop ourselves

# ---------------------------------------------
#  WIDGET STATE
# ---------------------------------------------
bpm: 90
isRunning: false
soundOn: false
audioCtx: null
nextBeat: 0
beatInterval: 0                       # set in afterRender
tapHistory: []
rafID: null

# ---------------------------------------------
#  UI
# ---------------------------------------------
render: -> """
  <style>
    :root {
      --mint: #CFE9DD;
      --glass-bg: rgba(15,18,28,0.45);
      --glass-border: rgba(255,255,255,0.08);
      --pulse-color: radial-gradient(circle at center, rgba(0,0,0,0.55), rgba(0,0,0,0.92));
    }
    html,body{margin:0;padding:0;background:transparent;font-family:-apple-system,BlinkMacSystemFont,"Helvetica Neue",sans-serif;color:#fff}
    .pulse{position:fixed;inset:0;background:var(--pulse-color);opacity:0;transition:opacity .12s ease-in-out;pointer-events:none;z-index:0}
    .controls{position:fixed;bottom:14px;left:14px;display:flex;align-items:center;gap:8px;z-index:10}
    .btn{width:38px;height:38px;border-radius:50%;border:1px solid var(--glass-border);background:var(--glass-bg);color:rgba(255,255,255,.85);display:flex;align-items:center;justify-content:center;cursor:pointer;user-select:none;backdrop-filter:blur(18px) saturate(130%);transition:all .25s ease;font-size:12px;font-weight:500}
    .btn.small{width:30px;height:30px;font-size:18px;line-height:0}
    .btn:hover{background:rgba(30,40,60,.55)}
    .btn.on{color:var(--mint);border-color:rgba(180,255,220,.25);box-shadow:0 0 6px rgba(180,255,220,.25);background:rgba(10,14,20,.6)}
    .bpm{width:72px;text-align:center;font-size:13px;color:rgba(255,255,255,.7);user-select:none}
    .bpm.active{color:var(--mint)}
    .sound svg{width:16px;height:16px;fill:none;stroke:currentColor;stroke-width:1.4;stroke-linecap:round;stroke-linejoin:round}
    .sound svg path.fill{fill:currentColor;stroke:none}
  </style>

  <div id="pulse" class="pulse"></div>
  <div class="controls">
    <div id="toggle" class="btn">OFF</div>
    <div id="tap"  class="btn">TAP</div>
    <div id="sound" class="btn sound" aria-label="Sound toggle">
      <svg viewBox="0 0 24 24">
        <path class="fill" d="M5 10.2h2.6L12 7v10l-4.4-3.2H5z"/>
        <path d="M15.5 8.5c1.1.9 1.8 2.2 1.8 3.5s-.7 2.7-1.8 3.5M18.6 6.6c1.8 1.4 2.8 3.6 2.8 5.4s-1 4-2.8 5.4"/>
      </svg>
    </div>
    <div id="down" class="btn small">−</div>
    <div id="bpm"  class="bpm">90 BPM</div>
    <div id="up"   class="btn small">+</div>
  </div>
"""

# ---------------------------------------------
#  LIFE-CYCLE
# ---------------------------------------------
afterRender: (el) ->
  # --- cache nodes ----------------------------------------------------------
  pulse     = el.querySelector '#pulse'
  toggleBtn = el.querySelector '#toggle'
  tapBtn    = el.querySelector '#tap'
  soundBtn  = el.querySelector '#sound'
  downBtn   = el.querySelector '#down'
  upBtn     = el.querySelector '#up'
  bpmLabel  = el.querySelector '#bpm'

  # --- audio -----------------------------------------------------------------
  ensureAudio = =>
    return @audioCtx if @audioCtx
    Ctor = window.AudioContext or window.webkitAudioContext
    @audioCtx = new Ctor()
    @audioCtx

  playClick = =>
    return unless @soundOn
    ctx = ensureAudio()
    ctx.resume()
    t = ctx.currentTime
    o = ctx.createOscillator()
    g = ctx.createGain()
    o.type = 'square'
    o.frequency.value = 900
    g.gain.setValueAtTime 0.0001, t
    g.gain.linearRampToValueAtTime 0.25, t + 0.005
    g.gain.exponentialRampToValueAtTime 0.0001, t + 0.09
    o.connect g
    g.connect ctx.destination
    o.start t
    o.stop t + 0.1

  # --- pulse -----------------------------------------------------------------
  pulseNow = =>
    pulse.style.opacity = 1
    pulse.offsetHeight          # force reflow
    setTimeout (-> pulse.style.opacity = 0), 100

  # --- main loop -------------------------------------------------------------
  tick = (time) =>
    if @isRunning
      t = time / 1000
      if t >= @nextBeat
        pulseNow()
        playClick()
        @nextBeat += @beatInterval
      @rafID = requestAnimationFrame tick
    else
      cancelAnimationFrame @rafID if @rafID

  # --- control helpers -------------------------------------------------------
  start = =>
    return if @isRunning
    @isRunning   = true
    @beatInterval = 60 / @bpm
    @nextBeat    = performance.now() / 1000
    toggleBtn.textContent = 'ON'
    toggleBtn.classList.add 'on'
    bpmLabel.classList.add 'active'
    @rafID = requestAnimationFrame tick

  stop = =>
    @isRunning = false
    pulse.style.opacity = 0
    toggleBtn.textContent = 'OFF'
    toggleBtn.classList.remove 'on'
    bpmLabel.classList.remove 'active'

  updateBpm = (v) =>
    @bpm = Math.max 20, Math.min 300, Math.round v
    bpmLabel.textContent = "#{@bpm} BPM"
    @beatInterval = 60 / @bpm if @isRunning

  # --- long-press BPM +/- ----------------------------------------------------
  holdButton = (btn, delta) =>
    hold = null
    btn.addEventListener 'pointerdown', =>
      updateBpm @bpm + delta
      hold = setInterval (=> updateBpm @bpm + delta), 120
    ['pointerup','pointerleave'].forEach (ev) =>
      btn.addEventListener ev, -> clearInterval hold if hold

  holdButton downBtn, -1
  holdButton upBtn,   +1

  # --- tap tempo -------------------------------------------------------------
  tapBtn.onclick = =>
    now = Date.now()
    @tapHistory.push now
    @tapHistory = @tapHistory.filter (t) -> now - t < 4000
    return if @tapHistory.length < 2
    sum = 0
    for i in [1...@tapHistory.length]
      sum += @tapHistory[i] - @tapHistory[i-1]
    avg = sum / (@tapHistory.length - 1)
    updateBpm 60000 / avg
    start() if @tapHistory.length >= 4 and not @isRunning

  # --- sound toggle ----------------------------------------------------------
  soundBtn.onclick = =>
    @soundOn = !@soundOn
    soundBtn.classList.toggle 'on', @soundOn

  # --- main toggle -----------------------------------------------------------
  toggleBtn.onclick = => if @isRunning then stop() else start()

  # initialise beat interval
  @beatInterval = 60 / @bpm
