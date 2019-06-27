using Blink

function myfun(w, arg)

    println("perro")
    div_id = "box"
        
    js_(w, Blink.JSString("""document.getElementById('box').style.background = 'blue'"""))
    # println(typeof(color))
    # if color != "red"
    #     js(w, Blink.JSString("""document.getElementById("$div_id").style= 'background:green;'"""), async=true)
    # else            
    #     js(w, Blink.JSString("""document.getElementById("$div_id").style= 'background:red;'"""), async=true)
    # end
end

function main()
    w = Window(async=true);
    # Set up julia to handle the "press" message:
    handle(w, "press") do args
        @show args
        myfun(w, 12)
    end
    # Invoke the "press" message from javascript whenever this button is pressed:
    body!(w, """<center>Automated Parameter Tuning</center>
                <button onclick='Blink.msg("press", "HELLO 2")'>Pon color</button>
                <div id="box" style="background:red; with:50px;height:50px;"></div>""",async=true);


end


# body!(win, """<div id="box" style="color:red;"></div>""", async=false);
# js(win, Blink.JSString("""document.getElementById("$div_id").style.color"""))


main()