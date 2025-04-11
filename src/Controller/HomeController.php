<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;

class HomeController extends AbstractController
{
    #[Route('/', name: 'app_home')]
    public function home(): Response
    {
        return $this->render('home/home.html.twig', []);
    }

    #[Route('/comment-ca-marche', name: 'app_how_it_works')]
    public function howItWorks(): Response
    {
        return $this->render('home/how_it_works.html.twig', []);
    }

    #[Route('/le-projet', name: 'app_project')]
    public function project(): Response
    {
        return $this->render('home/project.html.twig', []);
    }
}