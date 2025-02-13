const API_BASE_URL = 'http://localhost:5000/api';

export async function getAll(route, id) {
  const url = id !== null ? `${API_BASE_URL}/${route}?id=${id}` : `${API_BASE_URL}/${route}`;
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  });
  return await response.json();
}

export async function post(route, object) {
  const response = await fetch(`${API_BASE_URL}/${route}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(object),
  });
  return await response.json();
}

export async function update(route, object) {
  const response = await fetch(`${API_BASE_URL}/${route}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(object),
  });
  return await response.json();
}

export async function del(route, id) {
  const response = await fetch(`${API_BASE_URL}/${route}?id=${id}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
    },
  });
  return await response.json();
}
