fn _step(r: &mut [f32], d: &[f32], n: usize) {
    for i in 0..n {
        for j in 0..n {
            let mut v = std::f32::INFINITY;
            for k in 0..n {
                let x = d[n*i + k];
                let y = d[n*k + j];
                let z = x + y;
                v = v.min(z);
            }
            r[n*i + j] = v;
        }
    }
}
