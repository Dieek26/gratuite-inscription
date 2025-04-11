<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class SubscriptionController extends AbstractController
{
    #[Route('/subscription', name: 'app_subscription')]
    public function subscription(): Response
    {
        $number = random_int(0, 100);

        return $this->render('subscription/form.html.twig', [
            'random_number' => $number
        ]);
    }
}