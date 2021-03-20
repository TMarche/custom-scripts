
def print_reps(base, max_reps, warmup_sets=4):
    reps = calculate_reps(base, max_reps, warmup_sets)
    print(format_reps(reps))

def calculate_reps(base, max_reps, warmup_sets=4):
    reps = []
    increment = (max_reps - base) / warmup_sets
    for i in range(warmup_sets):
        weight = round_weight(base + i * increment)
        reps = reps + [weight]
    reps = reps + [max_reps]

    return reps

def format_reps(reps):
    s = (
        f"{reps[0]} x 5 x 1\n"
        f"{reps[1]} x 5 x 1\n"
        f"{reps[2]} x 3 x 1\n"
        f"{reps[3]} x 2 x 1\n"
        f"{reps[4]} x 5 x 3"
    )
    return s

def round_weight(x, base=5):
    return base * round(x/base)
