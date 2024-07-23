import Base: append!, push!

function add_integral_values!(A)
    integral_values = cumsum([_integral(A, idx, A.t[idx + 1]) - _integral(A, idx, A.t[idx])
                              for idx in (length(A.I) - 1):(length(A.t) - 1)])
    pop!(A.I)
    integral_values .+= last(A.I)
    append!(A.I, integral_values)
end

function push!(A::LinearInterpolation{U, T}, u::eltype(U), t::eltype(T)) where {U, T}
    push!(A.u.parent, u)
    push!(A.t.parent, t)
    slope = linear_interpolation_parameters(A.u, A.t, length(A.t) - 1)
    push!(A.p.slope, slope)
    add_integral_values!(A)
    A
end

function push!(A::QuadraticInterpolation{U, T}, u::eltype(U), t::eltype(T)) where {U, T}
    push!(A.u.parent, u)
    push!(A.t.parent, t)
    l₀, l₁, l₂ = quadratic_interpolation_parameters(A.u, A.t, length(A.t) - 2)
    push!(A.p.l₀, l₀)
    push!(A.p.l₁, l₁)
    push!(A.p.l₂, l₂)
    add_integral_values!(A)
    A
end

function push!(A::ConstantInterpolation{U, T}, u::eltype(U), t::eltype(T)) where {U, T}
    push!(A.u.parent, u)
    push!(A.t.parent, t)
    add_integral_values!(A)
    A
end

function append!(
        A::LinearInterpolation{ReadOnlyVector{eltypeU, U}, ReadOnlyVector{eltypeT, T}}, u::U, t::T) where {
        eltypeU, U, eltypeT, T}
    length_old = length(A.t)
    u, t = munge_data(u, t, true)
    append!(A.u.parent, u)
    append!(A.t.parent, t)
    slope = linear_interpolation_parameters.(
        Ref(A.u), Ref(A.t), length_old:(length(A.t) - 1))
    append!(A.p.slope, slope)
    add_integral_values!(A)
    A
end

function append!(
        A::ConstantInterpolation{ReadOnlyVector{eltypeU, U}, ReadOnlyVector{eltypeT, T}}, u::U, t::T) where {
        eltypeU, U, eltypeT, T}
    u, t = munge_data(u, t, true)
    append!(A.u.parent, u)
    append!(A.t.parent, t)
    add_integral_values!(A)
    A
end

function append!(
        A::QuadraticInterpolation{ReadOnlyVector{eltypeU, U}, ReadOnlyVector{eltypeT, T}}, u::U, t::T) where {
        eltypeU, U, eltypeT, T}
    length_old = length(A.t)
    u, t = munge_data(u, t, true)
    append!(A.u.parent, u)
    append!(A.t.parent, t)
    parameters = quadratic_interpolation_parameters.(
        Ref(A.u), Ref(A.t), (length_old - 1):(length(A.t) - 2))
    l₀, l₁, l₂ = collect.(eachrow(stack(collect.(parameters))))
    append!(A.p.l₀, l₀)
    append!(A.p.l₁, l₁)
    append!(A.p.l₂, l₂)
    add_integral_values!(A)
    A
end
