-- softcut-based risset rhythm
needs_redraw = true

file = "/home/we/dust/audio/tehn/drumev.wav"

n_channels, n_samples, sample_rate = audio.file_info(file)
dur = n_samples / sample_rate

min_rate = 0.0
max_rate = 100.0
n_vox_per_chan = 3
rate_tick_freq = 2
curr_rate = 50.0
rate_step = 1
rate_spread = max_rate / 3
center_rate = 50.0
double_rate = 25.0

loop_size = 0.1
min_scrub = 0.0
max_scrub = 100.0
curr_scrub = 50.0
scrub_step = 1.0
scrub_spread = max_scrub / 3
center_scrub = 50.0
double_scrub = 25.0

pos_step = -loop_size
scrub_pos = {0, 0, 0}
scrub_tick_freq = 3

min_fc = 0
max_fc = 100.0
fc_tick_freq = 100
curr_fc = 50.0
fc_step = -1
fc_spread = max_fc / 3
center_fc = 50.0
double_fc = 25.0

playheads = {0, 0, 0, 0, 0, 0}
samples = {}
cutoffs = {}

function init()
    params:add_separator("risset rhythm")
    params:add{
        id="rr_rate_tick_freq",
        name="rate tick freq",
        type="control",
        controlspec=controlspec.def{
            min=1,
            max=1000,
            step=1,
            default=2,
            units="hz",
        },
        action=function(val)
            rate_tick_freq=val
            for i=1,6 do
                softcut.rate_slew_time(i, 1/rate_tick_freq/2)
            end
        end,
    }
    params:add{
        id="rr_rate_step",
        name="rate step",
        type="control",
        controlspec=controlspec.def{
            min=-2,
            max=2,
            step=0.05,
            default=1,
        },
        action=function(val)
            rate_step=val
        end,
    }
    params:add{
        id="rr_rate_spread",
        name="rate spread",
        type="control",
        controlspec=controlspec.def{
            min=0,
            max=max_rate/3,
            step=1,
            default=max_rate/3,
        },
        action=function(val)
            rate_spread=val
        end,
    }

    params:add{
        id="rr_loop_size",
        name="loop size",
        type="control",
        controlspec=controlspec.def{
            min=0.01,
            max=1.0,
            step=0.01,
            default=0.1,
            units="s",
        },
        action=function(val)
            loop_size=val
            for i=1,6 do
                softcut.fade_time(i, loop_size/2)
            end
        end,
    }
    params:add{
        id="rr_pos_step",
        name="pos step",
        type="control",
        controlspec=controlspec.def{
            min=-2,
            max=2,
            step=0.01,
            default=1,
            units="s",
        },
        action=function(val)
            pos_step=val
        end,
    }
    params:add{
        id="rr_scrub_tick_freq",
        name="scrub tick freq",
        type="control",
        controlspec=controlspec.def{
            min=1,
            max=1000,
            step=1,
            default=2,
            units="hz",
        },
        action=function(val)
            scrub_tick_freq=val
        end,
    }
    params:add{
        id="rr_scrub_step",
        name="scrub step",
        type="control",
        controlspec=controlspec.def{
            min=-2,
            max=2,
            step=0.05,
            default=1,
        },
        action=function(val)
            scrub_step=val
        end,
    }
    params:add{
        id="rr_scrub_spread",
        name="scrub spread",
        type="control",
        controlspec=controlspec.def{
            min=0,
            max=max_scrub/3,
            step=1,
            default=max_scrub/3,
        },
        action=function(val)
            scrub_spread=val
        end,
    }

    params:add{
        id="rr_fc_tick_freq",
        name="cutoff tick freq",
        type="control",
        controlspec=controlspec.def{
            min=1,
            max=1000,
            step=1,
            default=2,
            units="hz",
        },
        action=function(val)
            fc_tick_freq=val
        end,
    }
    params:add{
        id="rr_fc_step",
        name="cutoff step",
        type="control",
        controlspec=controlspec.def{
            min=-2,
            max=2,
            step=0.05,
            default=1,
        },
        action=function(val)
            fc_step=val
        end,
    }
    params:add{
        id="rr_fc_spread",
        name="cutoff spread",
        type="control",
        controlspec=controlspec.def{
            min=0,
            max=max_fc/3,
            step=1,
            default=max_fc/3,
        },
        action=function(val)
            fc_spread=val
        end,
    }
    params:add{
        id="rr_rq",
        name="rq",
        type="control",
        controlspec=controlspec.RQ,
        action=function(val)
            for i=1,6 do
                softcut.post_filter_rq(i, val)
            end
        end,
    }
    params:add{
        id="rr_dry",
        name="dry level",
        type="control",
        controlspec=controlspec.UNIPOLAR,
        action=function(val)
            for i=1,6 do
                softcut.post_filter_dry(i, val)
            end
        end,
    }
    params:add{
        id="rr_bp",
        name="bandpass level",
        type="control",
        controlspec=controlspec.UNIPOLAR,
        action=function(val)
            for i=1,6 do
                softcut.post_filter_bp(i, val)
            end
        end,
    }
    params:add{
        id="rr_lp",
        name="lowpass level",
        type="control",
        controlspec=controlspec.UNIPOLAR,
        action=function(val)
            for i=1,6 do
                softcut.post_filter_lp(i, val)
            end
        end,
    }
    params:add{
        id="rr_hp",
        name="highpass level",
        type="control",
        controlspec=controlspec.UNIPOLAR,
        action=function(val)
            for i=1,6 do
                softcut.post_filter_hp(i, val)
            end
        end,
    }
    params:add{
        id="rr_br",
        name="bandreject level",
        type="control",
        controlspec=controlspec.UNIPOLAR,
        action=function(val)
            for i=1,6 do
                softcut.post_filter_br(i, val)
            end
        end,
    }

    softcut.buffer_clear()
    softcut.buffer_read_stereo(file, 0, 0, dur)
    softcut.phase_quant(1,0.025)
    softcut.event_phase(update_positions)
    softcut.poll_start_phase()
    softcut.event_render(on_render)
    softcut.render_buffer(1, 0, dur, 128)
    for i=1,6 do
        softcut.enable(i, 1)
        softcut.buffer(i, (i-1)//n_vox_per_chan+1)
        softcut.pan(i, util.linlin(1, 6, -1, 1, i))
        softcut.position(i, 0)
        softcut.loop(i, 1)
        softcut.loop_start(i, 0)
        softcut.loop_end(i, loop_size)
        softcut.rate_slew_time(i, 1/rate_tick_freq/2)
        softcut.fade_time(i, loop_size/2)
    end

    params:default()

    update_rates()
    update_filters()
    for i=1,6 do
        softcut.play(i, 1)
    end
    clock.run(rate_tick_loop)
    clock.run(fc_tick_loop)
    for i=1,3 do
        clock.run(scrub_loop(i))
    end
end

function update_positions(i, pos)
    playheads[i] = pos
    needs_redraw = true
end

function on_render(ch, start, i, s)
    samples = s
    needs_redraw = true
end

function refresh()
    redraw()
end

function redraw()
    if not needs_redraw then return end
    needs_redraw = false
    screen.clear()

    screen.level(3)
    local x_pos = 0
    for i,s in ipairs(samples) do
        local height = util.round(math.abs(s) * 25)
        screen.move(util.linlin(0,128,10,120,x_pos), 35 - height)
        screen.line_rel(0, 2 * height)
        screen.stroke()
        x_pos = x_pos + 1
    end

    screen.level(15)
    for i=1,3 do
        local p=scrub_pos[i]
        screen.move(util.linlin(0, dur, 10, 120, p), 0)
        screen.line_rel(0, 64)
        screen.stroke()
    end

    screen.level(8)
    for i=1,3 do
        local p=playheads[i]
        screen.move(util.linlin(0, dur, 10, 120, p), 0)
        screen.line_rel(0, 64)
        screen.stroke()
    end

    screen.level(12)
    for _, cutoff in ipairs(cutoffs) do
        screen.move(0, util.linlin(0, 100, 64, 0, cutoff))
        screen.line_rel(128, 0)
        screen.stroke()
    end

    screen.update()
end

function lin_amp(val, min, max)
    local half_width = (max - min) / 2
    local peak = half_width + min
    return 1 - math.abs(val - peak) / half_width
end

function cos_amp(val, min, max)
    local half_width = (max - min) / 2
    local peak = half_width + min
    return (1 + math.cos(math.pi * math.abs(val - peak) / half_width)) / 2
end

function gauss_amp(val, min, max, bell_width)
    local peak = (max + min) / 2
    return math.exp(-0.5 * ((val - peak) / bell_width)^2)
end

function wrap_val(val, min, max)
    local range = max - min
    return (val - min) % range + min
end

function gen_values(min, max, count, spread, center)
    local values = {}
    local center_index = count // 2
    local range = max - min
    for i = 1, count do
        local index = i - 1 - center_index
        values[i] = (index * spread + center) % range + min
    end
    return values
end

function rate_tick_loop()
    while true do
        rate_tick()
        clock.sleep(1/rate_tick_freq)
    end
end

function update_rates()
    local rates = gen_values(min_rate, max_rate, n_vox_per_chan, rate_spread, curr_rate)

    for b = 1, 2 do
        for i, rate in ipairs(rates) do
            local level = cos_amp(min_rate, max_rate, rate)
            local index = (b-1)*n_vox_per_chan+i
            local sc_rate = 2^((rate-center_rate)/double_rate)
            softcut.level(index, level)
            softcut.rate(index, sc_rate)
        end
    end
end

function rate_tick()
    update_rates()

    curr_rate = curr_rate + rate_step
    curr_rate = wrap_val(curr_rate, min_rate, max_rate)
end

function scrub_tick_loop()
    while true do
        scrub_tick()
        clock.sleep(1/scrub_tick_freq)
    end
end

function scrub_tick()
    curr_scrub = curr_scrub + scrub_step
    curr_scrub = wrap_val(curr_scrub, min_scrub, max_scrub)
end

function scrub_loop(index)
    return function()
        while true do
            local pos = scrub_pos[index]
            for i=1,2 do
                local voice = (i-1)*3+index
                softcut.position(voice, pos)
                softcut.loop_start(voice, pos)
                softcut.loop_end(voice, pos+loop_size)
            end
            pos = pos + pos_step
            pos = wrap_val(pos, 0, dur-loop_size)
            scrub_pos[index] = pos
            needs_redraw = true

            local scrubs = gen_values(min_scrub, max_scrub, n_vox_per_chan, scrub_spread, curr_scrub)
            local scrub = scrubs[index]
            local freq = util.linlin(min_scrub, max_scrub, 1, 10, scrub)
            clock.sleep(1/freq)
        end
    end
end


function update_filters()
    cutoffs = gen_values(min_fc, max_fc, n_vox_per_chan, fc_spread, curr_fc)

    for b = 1, 2 do
        for i, cutoff in ipairs(cutoffs) do
            local level = cos_amp(min_fc, max_fc, cutoff)
            local index = (b-1)*n_vox_per_chan+i
            local sc_fc = 440*2^((cutoff-center_fc)/double_fc)
            softcut.post_filter_fc(index, sc_fc)
        end
    end
end

function fc_tick()
    update_filters()
    curr_fc = curr_fc + fc_step
    curr_fc = wrap_val(curr_fc, min_fc, max_fc)
end

function fc_tick_loop()
    while true do
        fc_tick()
        clock.sleep(1/fc_tick_freq)
    end
end
