#[no_mangle]
pub extern "C" fn step(r_raw: *mut f32, d_raw: *const f32, n: i32) {
    let d = unsafe { std::slice::from_raw_parts(d_raw, (n * n) as usize) };
    let mut r = unsafe { std::slice::from_raw_parts_mut(r_raw, (n * n) as usize) };
    _step(&mut r, d, n as usize);
}
