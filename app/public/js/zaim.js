const zaim = {
  user(callback) {
    axios.get('/api/user').then(callback);
  }
}
