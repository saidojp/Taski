<template lang="pug">
div.login-container
  h1 Login
  form(@submit.prevent="handleLogin")
    input(v-model="email" type="email" placeholder="Email" required)
    input(v-model="password" type="password" placeholder="Password" required)
    button(type="submit") Login
  p
    | Don't have an account? 
    router-link(to="/signup") Sign up
</template>

<script setup>
import { ref } from 'vue';
import { useAuthStore } from '../stores/auth';
import { useRouter } from 'vue-router';

const email = ref('');
const password = ref('');
const authStore = useAuthStore();
const router = useRouter();

const handleLogin = async () => {
  const success = await authStore.login(email.value, password.value);
  if (success) {
    router.push('/dashboard');
  } else {
    alert('Login failed');
  }
};
</script>

<style scoped>
.login-container {
  max-width: 400px;
  margin: 50px auto;
  padding: 20px;
  border: 1px solid #ddd;
  border-radius: 8px;
}
input {
  display: block;
  width: 100%;
  padding: 8px;
  margin-bottom: 10px;
  box-sizing: border-box;
}
button {
  width: 100%;
  padding: 10px;
  background-color: #42b983;
  color: white;
  border: none;
  cursor: pointer;
}
</style>
