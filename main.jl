using Blink
using Plots
plotly()



function myfun(w, arg)

    println("perro")
    div_id = "box"

    println("gato")

    @js_ w begin
        @var box = document.getElementById("box")
        box.style.background = box.style.background == "blue" ? "green" : "blue"

    end

end

function main()
    w = Window(async=true);
    load!(w, "materialize/js/materialize.js")
    load!(w, "materialize/css/materialize.min.css")


    # Set up julia to handle the "press" message:
    handle(w, "press") do args
        @show args
        myfun(w, 12)
    end

    # Set up julia to handle the "press" message:
    handle(w, "press2") do args

        println("hola desde 2")
        @js_ w begin
                @var box = document.getElementById("box2")
                box.style.background = box.style.background == "blue" ? "green" : "blue"
        end
    end

    title(w, "BCAP")
    progress(w)



    body!(w, read("index.html", String))
    load!(w, "style.css")
    load!(w, "engine.js")


    # body!(w, """<center>Automated Parameter Tuning</center>
    #             <button onclick='Blink.msg("press", "HELLO 2")'>Pon color</button>
    #             <div id="box" style="background:red; with:50px;height:50px;"></div>""", async=false);


end


# body!(win, """<div id="box" style="color:red;"></div>""", async=false);
# js(win, Blink.JSString("""document.getElementById("$div_id").style.color"""))


main()