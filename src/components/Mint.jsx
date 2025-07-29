import { useState } from 'react';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';
import Spinner from 'react-bootstrap/Spinner';

const Mint = ({ provider, nft, cost, setIsLoading }) => {
  const [isWaiting, setIsWaiting] = useState(false)

  const mintHandler = async (e) => {
    e.preventDefault()
    setIsWaiting(true)

    try {
      const signer = await provider.getSigner()
      const transaction = await nft.connect(signer).mint(1, { value: cost })
      await transaction.wait()
    } catch (error) {
      console.error('Minting error:', error)
      
      // Provide specific error messages
      if (error.code === 4001) {
        window.alert('Transaction rejected by user')
      } else if (error.message.includes('insufficient funds')) {
        window.alert('Insufficient funds for transaction')
      } else if (error.message.includes('Minting not allowed yet')) {
        window.alert('Minting not allowed yet - please wait')
      } else if (error.message.includes('Exceeds maximum supply')) {
        window.alert('Sorry, all NFTs have been minted!')
      } else if (error.message.includes('Insufficient payment')) {
        window.alert('Insufficient payment - please check the cost')
      } else if (error.message.includes('permanently disabled')) {
        window.alert('Minting has been permanently disabled')
      } else {
        window.alert('Transaction failed: ' + (error.reason || error.message || 'Unknown error'))
      }
    }

    setIsLoading(true)
  }

  return(
    <Form onSubmit={mintHandler} style={{ maxWidth: '350px', margin: '50px auto' }}>
      {isWaiting ? (
        <Spinner animation="border" style={{ display: 'block', margin: '0 auto' }} />
      ) : (
        <Form.Group>
          <Button variant="primary" type="submit" style={{ width: '100%' }}>
            Mint
          </Button>
        </Form.Group>
      )}

    </Form>
  )
}

export default Mint;
