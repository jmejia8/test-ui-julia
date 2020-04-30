function targetAlgorithm(parameters, instance, seed)

    f(x) = sum((x .-  2) .^ 2) + 0.1rand()

    fx = f(parameters)

    if rand() > 0.599
        return 0.0
    end

    return fx < 0.1 ?  0.0 : fx
end
