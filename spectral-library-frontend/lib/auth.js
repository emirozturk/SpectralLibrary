import md5 from 'md5'

export const calculateMD5 = (password) => {
  return md5(password)
}
